#!/bin/bash
#Copyright© 2000-2019 CNflysky. <cnflysky@qq.com> All rights Reserved.
#last edited by CNflysky 2019.4.15
#变量
dir="/opt"
sversion="0.15 Alpha"
currentime=$(date "+%m%d")
name=""
#变量
#函数
backup(){
if screen -ls mc | grep -q mc ;then
screen -x -S mc -p 0 -X stuff "save hold"
screen -x -S mc -p 0 -X stuff "\n"
fi
echo "正在等待服务器保存存档,大约需要5s..."
sleep 5s
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
read -p "由于Minecraft官方网站服务器位于境外,从服务器获取版本信息可能需要一段时间,请选择是否手动输入版本号(1:手动,默认自动):" manual
echo "正在获取版本信息...."
if [ -n "$manual" ] && [ $manual -eq 1 ]; then
read -p "请输入版本号(说明:需要输入完整版本号,示例:1.10.0.7)" sver
else
rawhtml=$(curl https://www.minecraft.net/en-us/download/server/bedrock | grep bin-linux)
rawlink=${rawhtml#*r-}
sver=${rawlink%.z*}
fi
}
setProp(){
read -p "请输入服务器端口(默认19132):" port
read -p "请输入服务器描述(按下Enter跳过[请勿输入带空格的字符]):" describe
read -p "请选择是否打开白名单(输入任意字符开启,默认不开启):" whitelist
read -p "请选择游戏模式(0:生存,1:创造,2:冒险,默认生存):" mode
read -p "请选择难度(0:和平,1:简单,2:普通,3:困难,默认普通):" difficulty
read -p "请输入世界种子(留空则随机):" seed
read -p "请输入服务器玩家人数上限(默认10人):" playerslimit
if [ -n "$port" ] || [ -n "$describe" ] || [ -n "$whitelist" ] || [ -n "$seed" ] || [ -n "$mode" ] || [ -n "$difficulty" ] || [ -n "$playerslimit" ]; then 
echo "请核对服务器信息:"
if [ -n "$port" ]; then 
echo "端口:$port"
fi
if [ -n "$describe" ]; then 
echo "描述:$describe"
fi
if [ -n "$whitelist" ]; then 
echo "白名单:开启"
fi
if [ -n "$mode" ]; then 
echo "模式:$mode"
fi
if [ -n "$difficulty" ]; then 
echo "难度:$difficulty"
fi
if [ -n "$seed" ]; then 
echo "种子:$seed"
fi
if [ -n "$playerslimit" ]; then 
echo "玩家上限:$playerslimit"
fi
fi
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
if [ -n "$whitelist" ]; then
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
echo "服务器已停止!"
else
echo "服务器未在运行!"
fi
}
openServer(){
if screen -ls mc | grep -q mc ;then
echo "服务器已在运行!"
else
cd $dir/mc
screen -dmS mc ./bedrock_server
echo "服务器启动成功."
fi
}
#函数
if [ "$1"x = "-b"x ]; then 
backup
exit
fi
if [ ! `whoami` == "root" ];then
echo "请使用root用户运行该脚本!"
exit
fi
echo "-------Minecraft BE Server Manager By CNflysky v$sversion------"
echo "请输入数字选择您需要的功能:"
echo "1:安装 Minecraft BE服务器"
echo "2:升级 Minecraft BE服务器"
echo "3:卸载 Minecraft BE服务器"
echo "4:启动 Minecraft BE服务器"
echo "5:停止 Minecraft BE服务器"
echo "6:重启 Minecraft BE服务器"
echo "7:修改 Minecraft BE服务器配置"
echo "8:进入 Minecraft BE服务器控制台"
echo "9:将玩家ID加入白名单"
echo "10:将玩家ID移出白名单"
echo "11:手动备份服务器配置文件与存档"
echo "12:从已备份的文件中恢复配置文件与存档"
echo "13:安装 自动备份服务"
echo "14:卸载 自动备份服务"
echo "15:查看服务器使用说明(如何进入后台,自动备份服务说明...)"
echo "16:手动编辑服务器配置文件"
echo "17:升级本脚本"
echo "18:关于作者"
echo "---------------------------------------------------------------"
if [ ! -f "/usr/local/bin/mc" ]; then
mv install.sh $dir
ln -s $dir/install.sh /usr/local/bin/mc
fi
if [ -d $dir/mc ]; then
installedver=$(cat $dir/mc/version)
echo "服务器已安装版本:$installedver"
if screen -ls | grep -q mc ; then
echo "服务器状态:已安装 且 已启动!"
else 
echo "服务器状态:已安装 且 未启动!"
fi
else
echo "服务器状态:未安装"
fi
echo "提示:第一次打开脚本后请直接输入mc以打开本界面!"
read -p "请输入数字[1-18]:" function
if [ ! "$function" = 1  ] && [ ! -d "$dir/mc" ]; then
echo "未发现服务器安装目录!"
exit
fi
case $function in 
1)
if [ -d "$dir/mc" ]; then
echo "服务器已安装!"
else
apt -y update 
apt -y install axel screen zip unzip curl libssl-dev
grep -q $dir/mc /etc/ld.so.conf
if [ $? -ne 0 ];then
echo "$dir/mc" >> /etc/ld.so.conf
fi
setProp
read -p "按下Enter开始安装,取消请按下Ctrl+C" val
cd $dir
mkdir mc 
cd mc 
echo "正在从服务器获取版本信息..."
getVersion
axel -n 20 -o server.zip "https://minecraft.azureedge.net/bin-linux/bedrock-server-$sver.zip"
if [ ! -f "server.zip" ]; then
echo "无法下载服务端."
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
echo "服务器已启动!"
rm server.zip
fi
;;
2)
echo "正在检测新版本..."
getVersion
if [ "$installedver" = "$sver" ]; then
echo "已是最新版本."
else
read -p "发现新版本$sver,是否更新?输入yes确认更新:" confirmupdate
if [ -n "$confirmupdate" ] && [ "$confirmupdate"x = "yes"x ]; then
shutdownServer
cd $dir
axel -n 20 -o server.zip "https://minecraft.azureedge.net/bin-linux/bedrock-server-$sver.zip"
if [ ! -f "server.zip" ]; then
echo "无法下载服务端."
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
echo "升级完成."
openServer
else 
echo "用户取消."
fi
fi
;;
3)
read -p "警告:该操作会从你的系统中彻底卸载Minecraft BE服务器以及其他组件!真的要继续吗?请输入yes确认操作! " confirmremove
if [ -n "$confirmremove" ] && [ "$confirmremove"x = "yes"x ]; then
shutdownServer
rm -rf $dir/mc
rm -rf $dir/backups
crontab -r
echo "卸载完成."
else
echo "用户取消."
fi
;;
4)
openServer
;;
5)
shutdownServer
;;
6)
shutdownServer
sleep 5s #awaiting for command executing...
openServer
;;
7)
read -p "本操作会删除旧配置,是否继续(yes)?" confirmmod
if [ -n "$confirmmod" ] && [ "$confirmmod"x = "yes"x ]; then 
shutdownServer
cd $dir/mc
setProp
rm server.properties
cp server.properties.backup server.properties
applyProp
echo "修改完成"
openServer
else
echo "操作取消."
fi
;;
8)
openServer
echo "注意:如要退出控制台,请按下Ctrl + A + D,切勿使用Ctrl+C或者是直接关闭终端,否则会导致服务器停止!"
read -p "按下任意键继续..." var3
screen -r mc
;;
9)
openServer
read -p "请输入玩家名称,支持带有空格的名称，不需要使用双引号\"\":" name
screen -x -S mc -p 0 -X stuff "whitelist add \"$name\" "
screen -x -S mc -p 0 -X stuff "\n"
sleep 1s
if grep -q -w "$name" $dir/mc/whitelist.json ; then
echo "添加成功."
else
echo "添加失败."
fi
;;
10)
openServer
read -p "请输入玩家名称,支持带有空格的名称，不需要使用双引号\"\":" name
if grep -q -w "$name" $dir/mc/whitelist.json ; then
screen -x -S mc -p 0 -X stuff "whitelist remove \"$name\" "
screen -x -S mc -p 0 -X stuff "\n"
sleep 1s
if grep -q -w "$name" $dir/mc/whitelist.json ; then
echo "移除失败."
else
echo "移除成功."
fi
else
echo "未找到该玩家."
fi
;;
11)
if [ ! -d "$dir/backups" ]; then
mkdir $dir/backups
fi
backup
echo "备份完成,文件名为backup_$currentime.zip,路径在$dir/backups下"
;;
12)
if [ -d "$dir/backups" ]; then
echo "备份文件列表:"
ls $dir/backups
read -p "请输入您需要恢复的存档日期(下划线后面的那个四位数):" backupdate
if [ -f "$dir/backups/backup_$backupdate.zip" ]; then
read -p "此操作无法撤销!您真的要继续吗?退出请按下Ctrl+C,继续请输入yes!" confirmrestore
if [ -n "$confirmrestore" ] && [ "$confirmrestore"x = "yes"x ]; then
shutdownServer
sleep 2s
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
echo "恢复完成!"
cd $dir
rm -rf temp
fi
else
echo "未发现该日期的备份文件!"
fi
else
echo "未发现备份文件目录!"
fi
;;
13)
if [ -f "/var/spool/cron/crontabs/$LOGNAME" ]; then
cat /var/spool/cron/crontabs/$LOGNAME | grep -q install.sh
if [ $? -eq 0 ]; then
echo "已安装自动备份服务!"
exit
fi
fi
if [ ! -d "$dir/backups" ]; then
mkdir $dir/backups
fi
touch $dir/backups/croncmd
echo "0 0 * * * $dir/install.sh -b" >> $dir/backups/croncmd
echo "0 0 * * * find $dir/backups -mtime +6 -exec rm {} \;" >> $dir/backups/croncmd
cd $dir/backups/ && crontab croncmd
rm croncmd
echo "已成功安装 自动备份服务!"
;;
14)
crontab -r
echo "已成功卸载 自动备份服务!"
;;
15)
echo "由于linux的一些特性,直接关闭窗口会导致服务器停止"
echo "本脚本采用screen窗口以解决该问题"
echo "如果要退出服务器控制台的话,请按下组合键Ctrl+a+d再关闭终端"
echo "如果想要再次进入服务器后台,请输入screen -r mc"
echo "上传/下载存档可以使用SFTP,具体请百度"
echo "存档完整路径为$dir/mc/worlds"
echo "白名单用法:whitelist add xxxxx 添加xxx玩家"
echo "whitelist remove xxxxx 封禁xxx玩家"
echo "如果玩家名称带有空格请使用英文引号引用:whitelist add \"xxx xxx\""
echo "自动备份服务说明:每天0点自动备份,备份文件保留7天"
;;
16)
if [ -f "$dir/mc/server.properties" ]; then
nano $dir/mc/server.properties
else
echo "未找到配置文件."
fi
;;
17)
echo "正在检查新版本..."
rawfile=$(curl -s https://raw.githubusercontent.com/CNflysky/BDSDeploy/master/install.sh | grep "sversion=\"" )
rawv=${rawfile#*=\"}
scriptver=${rawv%\"}
sleep 0.5s
if [ "$scriptver" = "$sversion" ]; then
echo "已是最新版本."
else
read -p "发现新版本$scriptver,是否升级脚本?请输入yes确认升级!" update
if [ "$update" = "yes" ]; then
wget -N --no-check-certificate https://raw.githubusercontent.com/CNflysky/BDSDeploy/master/install.sh
echo "升级完成!"
exit
else
echo "中止."
fi
fi
;;
18)
echo "Copyright© 2000-2019 CNflysky <cnflysky@qq.com>.All rights Reserved."
echo "如有bug请及时反馈至作者邮箱!"
echo "作者qq:1450971394"
;;
*)
echo "请输入正确的数字!"
esac
