#!/bin/bash
#Copyright© 2000-2019 CNflysky. <cnflysky@qq.com> All rights Reserved.
#last edited by CNflysky 2019.7.17
#变量
dir="/opt"
sversion="0.1 Alpha"
currentime=$(date "+%m%d")
#变量
#函数
backup(){
if screen -ls mc | grep -q mc ;then
screen -x -S mc -p 0 -X stuff "save hold"
screen -x -S mc -p 0 -X stuff "\n"
fi
{ for ((i = 0 ; i <= 100 ; i+=20)); do
sleep 1
echo $i
done } | whiptail --gauge "正在等待服务器保存存档..." 6 60 0
if [ -f "$dir/backups/backup_$currentime.zip" ]; then
rm -f $dir/backups/backup_$currentime.zip
fi
cd $dir
mkdir temp
cp mc/{whitelist.json,permissions.json,server.properties} $dir/temp
cp -r mc/worlds $dir/temp
cd temp/
zip -r backup_$currentime.zip ./*
cp -f backup_$currentime.zip $dir/backups
cd $dir
rm -rf temp
if screen -ls mc | grep -q mc ;then
screen -x -S mc -p 0 -X stuff "save resume"
screen -x -S mc -p 0 -X stuff "\n"
fi
}
getVersion(){
if (whiptail --title "提示" --yesno "由于Minecraft官方网站服务器位于境外,从服务器获取版本信息可能需要一段时间,是否自动获取版本号？" 10 60) then 
rawhtml=$(curl https://www.minecraft.net/en-us/download/server/bedrock | grep bin-linux)
rawlink=${rawhtml#*r-}
sver=${rawlink%.z*}
else
port=$(whiptail --title "提示" --inputbox "请输入版本号(说明:需要输入完整版本号,示例:1.10.0.7)" 10 60 3>&1 1>&2 2>&3)
fi
}
setProp(){
port=$(whiptail --title "提示" --inputbox "请输入服务器端口:" 10 60 19132 3>&1 1>&2 2>&3)
describe=$(whiptail --title "提示" --inputbox "请输入服务器描述:" 10 60 "Dedicated Server" 3>&1 1>&2 2>&3)
whiptail --title "提示" --yesno "是否打开白名单?" 10 60
whitelist=$?
mode=$(whiptail --title "提示" --menu "请选择游戏模式" 15 60 4 \
"0" "生存" \
"1" "创造" \
"2" "冒险"  3>&1 1>&2 2>&3)
difficulty=$(whiptail --title "提示" --menu "选择游戏难度" 15 60 4 \
"0" "和平" \
"1" "简单" \
"2" "普通" \
"3" "困难"  3>&1 1>&2 2>&3)
seed=$(whiptail --title "提示" --inputbox "请输入世界种子:" 10 60   3>&1 1>&2 2>&3)
playerslimit=$(whiptail --title "提示" --inputbox "请输入服务器人数限制:" 10 60 10 3>&1 1>&2 2>&3)
}
applyProp(){
if [ -n "$seed" ]; then 
sed -i 's/level-seed=/level-seed='$seed'/g' server.properties
fi
if [ -n "$describe" ]; then 
sed -i 's/Dedicated Server/'$describe'/g' server.properties
fi
if [ -n "$port" ]; then
sed -i 's/server-port=19132/server-port='$port'/g' server.properties
fi
if [ $whitelist -eq 0 ]; then
sed -i 's/white-list=false/white-list=true/g' server.properties
fi
if [ -n "$mode" ] && [ "$mode"x = "1"x ]; then
sed -i 's/gamemode=survival/gamemode=creative/g' server.properties
fi
if [ -n "$mode" ] && [ "$mode"x = "2"x ]; then
sed -i 's/gamemode=survival/gamemode=adventure/g' server.properties
fi
if [ -n "$difficulty" ] && [ "$difficulty"x = "0"x ]; then
sed -i 's/difficulty=easy/difficulty=peaceful/g' server.properties
fi
if [ -n "$difficulty" ] && [ "$difficulty"x = "2"x ]; then
sed -i 's/difficulty=easy/difficulty=normal/g' server.properties
fi
if [ -n "$difficulty" ] && [ "$difficulty"x = "3"x ]; then
sed -i 's/difficulty=easy/difficulty=hard/g' server.properties
fi
if [ -n "$playerslimit" ]; then
sed -i 's/max-players=10/max-player='$playerslimit'/g' server.properties
fi
}
shutdownServer(){
if screen -ls mc | grep -q mc ;then
screen -x -S mc -p 0 -X stuff stop
screen -x -S mc -p 0 -X stuff "\n"
{ for ((i = 0 ; i < 100 ; i++)); do
sleep 0.02
echo $i
done } | whiptail --gauge "正在关闭服务器..." 6 60 0
whiptail --title "提示" --msgbox "服务器已关闭!" 10 60
else
whiptail --title "提示" --msgbox "服务器未在运行!" 10 60
fi
}
openServer(){
if screen -ls mc | grep -q mc ;then
whiptail --title "提示" --msgbox "服务器已启动!" 10 60
else
cd $dir/mc
screen -dmS mc ./bedrock_server
{ for ((i = 0 ; i < 100 ; i++)); do
sleep 0.01
echo $i
done } | whiptail --gauge "正在启动服务器..." 6 60 0
whiptail --title "提示" --msgbox "服务器已启动!" 10 60
fi
}
#函数
if [ "$1"x = "-b"x ]; then 
backup
exit
fi
if [ ! `whoami` == "root" ];then
whiptail --title "错误" --msgbox "请使用root权限运行该脚本!" 10 60
exit
fi
if [ ! -f "/usr/local/bin/mc" ]; then
mv install_ui.sh $dir
ln -s $dir/install_ui.sh /usr/local/bin/mc
fi
if [ -d $dir/mc ]; then
installedver=$(cat $dir/mc/version)
if screen -ls | grep -q mc ; then
str="已安装 且 已启动!"
else
str="已安装 且 未启动!"
fi
else
installedver="未知"
str="未安装"
fi
function=$(whiptail --title "Minecraft BE Server Manager By CNflysky v$sversion" --menu "请选择您需要的功能\n服务器版本:$installedver,状态:$str" 19 60 10 \
"1" "安装 Minecraft BE 服务器" \
"2" "升级 Minecraft BE服务器" \
"3" "卸载 Minecraft BE服务器" \
"4" "启动 Minecraft BE服务器" \
"5" "停止 Minecraft BE服务器" \
"6" "重启 Minecraft BE服务器" \
"7" "修改 Minecraft BE服务器配置" \
"8" "进入 Minecraft BE服务器控制台" \
"9" "将玩家ID加入白名单" \
"10" "将玩家ID移出白名单" \
"11" "手动备份服务器配置文件与存档" \
"12" "从已备份的文件中恢复配置文件与存档" \
"13" "安装 自动备份服务" \
"14" "卸载 自动备份服务" \
"15" "查看脚本使用说明" \
"16" "手动编辑服务器配置文件" \
"17" "升级本脚本" \
"18" "关于作者" \
3>&1 1>&2 2>&3)
if [ ! "$function" = 1  ] && [ ! -d "$dir/mc" ]; then
whiptail --title "错误" --msgbox "未发现服务器安装目录!" 10 60
exit
fi
case $function in 
1)
if [ -d "$dir/mc" ]; then
whiptail --title "错误" --msgbox "服务器已安装!" 10 60
else
apt -y update 
apt -y install axel screen zip unzip curl libssl-dev
grep -q $dir/mc /etc/ld.so.conf
if [ $? -ne 0 ];then
echo "$dir/mc" >> /etc/ld.so.conf
fi
setProp
cd $dir
mkdir mc 
cd mc 
getVersion
axel -n 20 -o server.zip "https://minecraft.azureedge.net/bin-linux/bedrock-server-$sver.zip"
if [ ! -f "server.zip" ]; then
whiptail --title "错误" --msgbox "无法下载服务端!" 10 60
rm -rf mc
exit
fi
unzip server.zip
cp server.properties server.properties.backup
touch version | echo "$sver" >> version
applyProp
ldconfig
chmod 755 bedrock_server 
screen -dmS mc ./bedrock_server
whiptail --title "提示" --msgbox "服务器已启动!" 10 60
rm server.zip
fi
;;
2)
getVersion
if [ "$installedver" = "$sver" ]; then
whiptail --title "提示" --msgbox "已是最新版本." 10 60
else
if (whiptail --title "提示" --yesno "发现新版本$sver,是否升级?" 10 60) then 
shutdownServer
cd $dir
axel -n 20 -o server.zip "https://minecraft.azureedge.net/bin-linux/bedrock-server-$sver.zip"
if [ ! -f "server.zip" ]; then
whiptail --title "错误" --msgbox "无法下载升级包!" 10 60
exit
fi
mkdir mc-temp
mv server.zip mc-temp
cd mc-temp
unzip server.zip
touch version | echo "$sver" >> version
rm server.zip
cd $dir/mc
cp -r worlds $dir/mc-temp
cp server.properties $dir/mc-temp
cp whitelist.json $dir/mc-temp
cd $dir
rm -rf mc
mv mc-temp mc
openServer
whiptail --title "提示" --msgbox "升级成功!" 10 60
else 
whiptail --title "错误" --msgbox "用户取消操作" 10 60
fi
fi
;;
3)
if (whiptail --title "提示" --yesno "您真的要卸载吗？" 10 60) then 
shutdownServer
rm -rf $dir/mc
rm -rf $dir/backups
crontab -r
whiptail --title "提示" --msgbox "卸载完成!" 10 60
else
whiptail --title "错误" --msgbox "用户取消!" 10 60
fi
;;
4)
openServer
;;
5)
shutdownServer
;;
6)
screen -x -S mc -p 0 -X stuff "stop"
screen -x -S mc -p 0 -X stuff "\n"
{ for ((i = 0 ; i < 100 ; i++)); do
sleep 0.05
echo $i
done } | whiptail --gauge "正在重新启动服务器..." 6 60 0
cd $dir && screen -dmS mc ./bedrock_server
whiptail --title "提示" --msgbox "重启完成" 10 60
;;
7)
if (whiptail --title "提示" --yesno "本操作会删除旧配置，是否继续？" 10 60) then 
shutdownServer
cd $dir/mc
setProp
rm server.properties
cp server.properties.backup server.properties
applyProp
whiptail --title "提示" --msgbox "修改完成!" 10 60
openServer
else
whiptail --title "错误" --msgbox "用户取消!" 10 60
fi
;;
8)
openServer
whiptail --title "提示" --msgbox "注意:如要退出控制台,请按下Ctrl + A + D,切勿使用Ctrl+C或者是直接关闭终端,否则会导致服务器停止!" 10 60
screen -r mc
;;
9)
openServer
name=$(whiptail --title "提示" --inputbox "请输入玩家名称,支持带有空格的名称，不需要使用双引号\"\":" 10 60  3>&1 1>&2 2>&3)
screen -x -S mc -p 0 -X stuff "whitelist add \"$name\" "
screen -x -S mc -p 0 -X stuff "\n"
sleep 1s
if grep -q -w "$name" $dir/mc/whitelist.json ; then
whiptail --title "提示" --msgbox "添加成功!" 10 60
else
whiptail --title "错误" --msgbox "添加失败!" 10 60
fi
;;
10)
openServer
name=$(whiptail --title "提示" --inputbox "请输入玩家名称,支持带有空格的名称，不需要使用双引号\"\":" 10 60  3>&1 1>&2 2>&3)
if grep -q -w "$name" $dir/mc/whitelist.json ; then
screen -x -S mc -p 0 -X stuff "whitelist remove \"$name\" "
screen -x -S mc -p 0 -X stuff "\n"
sleep 1s
if grep -q -w "$name" $dir/mc/whitelist.json ; then
whiptail --title "提示" --msgbox "移除失败!" 10 60
else
whiptail --title "错误" --msgbox "移除成功!" 10 60
fi
else
whiptail --title "错误" --msgbox "未找到该玩家!" 10 60
fi
;;
11)
if [ ! -d "$dir/backups" ]; then
mkdir $dir/backups
fi
backup
whiptail --title "提示" --msgbox "备份完成,文件名为backup_$currentime.zip,路径在$dir/backups下!" 10 60
;;
12)
if [ -d "$dir/backups" ]; then
list=$(ls $dir/backups)
backupdate=$(whiptail --title "提示" --inputbox "备份文件列表:$list \n请输入文件日期[下划线后四位数:]:" 10 60 19132 3>&1 1>&2 2>&3)
if [ -f "$dir/backups/backup_$backupdate.zip" ]; then
if (whiptail --title "提示" --yesno "是否确认?该操作无法撤销!" 10 60) then
shutdownServer
cd $dir
mkdir temp
cp $dir/backups/backup_$backupdate.zip temp/
cd temp
unzip backup_$backupdate.zip
cp -f server.properties $dir/mc
cp -f whitelist.json $dir/mc
rm -rf $dir/mc/worlds
cp -r worlds/ $dir/mc/
cd $dir/mc
openServer
whiptail --title "提示" --msgbox "恢复完成!" 10 60
cd $dir
rm -rf temp
fi
else
whiptail --title "提示" --msgbox "未发现该文件!" 10 60
fi
else
whiptail --title "错误" --msgbox "未发现备份文件目录!" 10 60
fi
;;
13)
if [ -f "/var/spool/cron/crontabs/$LOGNAME" ]; then
cat /var/spool/cron/crontabs/$LOGNAME | grep -q install_ui.sh
if [ $? -eq 0 ]; then
whiptail --title "错误" --msgbox "已安装 自动备份服务!" 10 60
exit
fi
fi
if [ ! -d "$dir/backups" ]; then
mkdir $dir/backups
fi
touch $dir/backups/croncmd
echo "0 0 * * * $dir/install_ui.sh -b" >> $dir/backups/croncmd
echo "0 0 * * * find $dir/backups -mtime +6 -exec rm {} \;" >> $dir/backups/croncmd
cd $dir/backups/ && crontab croncmd
rm croncmd
whiptail --title "提示" --msgbox "已成功安装 自动备份服务!" 10 60
;;
14)
crontab -r
whiptail --title "提示" --msgbox "已成功卸载 自动备份服务!" 10 60
;;
15)
whiptail --title "提示" --msgbox "由于linux的一些特性,直接关闭窗口会导致服务器停止\n本脚本采用screen窗口以解决该问题\n如果要退出服务器控制台的话,请按下组合键Ctrl+a+d再关闭终端\n如果想要再次进入服务器后台,请输入screen -r mc\n上传/下载存档可以使用SFTP,具体请百度\n存档完整路径为$dir/mc/worlds\n白名单用法:whitelist add xxxxx 添加xxx玩家\nwhitelist remove xxxxx 封禁xxx玩家\n如果玩家名称带有空格请使用英文引号引用:whitelist add \"xxx xxx\"\n自动备份服务说明:每天0点自动备份,备份文件保留7天" 20 60
;;
16)
if [ -f "$dir/mc/server.properties" ]; then
nano $dir/mc/server.properties
else
whiptail --title "错误" --msgbox "未找到配置文件!" 10 60
fi
;;
17)
rawfile=$(curl -s https://raw.githubusercontent.com/CNflysky/BDSDeploy/master/install_ui.sh | grep "sversion=\"" )
rawv=${rawfile#*=\"}
scriptver=${rawv%\"}
sleep 0.5s
if [ "$scriptver" = "$sversion" ]; then
whiptail --title "提示" --msgbox "已是最新版本!" 10 60
else
if (whiptail --title "提示" --yesno "发现新版本$scriprver,是否升级?" 10 60) then
rm -rf $dir/install_ui.sh
wget -N --no-check-certificate https://raw.githubusercontent.com/CNflysky/BDSDeploy/master/install_ui.sh
whiptail --title "提示" --msgbox "升级完成!" 10 60
exit
else
whiptail --title "错误" --msgbox "用户取消!" 10 60
fi
fi
;;
18)
whiptail --title "信息" --msgbox "Copyright© 2000-2019 CNflysky <cnflysky@qq.com>.All rights Reserved.\n如有bug请及时反馈至作者邮箱!\n作者qq:1450971394" 10 60
;;
*)
esac