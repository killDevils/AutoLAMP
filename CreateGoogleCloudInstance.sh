#!/bin/bash

gcloud config set project defaultdefault

echo -e "\e[1;41m正在罗列项目……\e[0m"
projectList=$(gcloud projects list | awk '!/NAME/{ print $1}')
export PS3=$'\e[1;41m你想进入哪一个项目？请输入数字并回车： \e[0m'
select projectOption in $projectList
do
	case $projectOption in
		*) projectName=$projectOption
	esac
	break
done
echo
echo -e "\e[1;31m你选择的项目是\e[0m\e[1;41m $projectName \e[0m"
gcloud config set project $projectName
echo
echo
echo

echo -e "\e[1;42m正在罗列国家/地区……\e[0m"
export PS3=$'\e[1;42m你想进入哪一个国家/地区？请输入数字并回车： \e[0m'
select regionName in "香港" "台湾" "日本东京" "日本大阪" "印度孟买" "新加坡" "悉尼" "加拿大蒙特利尔" "巴西圣保罗" "美中-艾奥瓦" "美东-南卡莱罗纳" "美东-北弗吉尼亚" "美西-俄勒冈州" "美西-洛杉矶" "芬兰" "比利时" "伦敦" "法兰克福" "荷兰" "苏黎世"
do
	case $regionName in
		香港) regionCode="asia-east2";;
		台湾) regionCode="asia-east1";;
		日本东京) regionCode="asia-northeast1";;
		日本大阪) regionCode="asia-northeast2";;
		印度孟买) regionCode="asia-south1";;
		新加坡) regionCode="asia-southeast1";;
		悉尼) regionCode="australia-southeast1";;
		加拿大蒙特利尔) regionCode="northamerica-northeast1";;
		巴西圣保罗) regionCode="southamerica-east1";;
		美中-艾奥瓦) regionCode="us-central1";;
		美东-南卡莱罗纳) regionCode="us-east1";;
		美东-北弗吉尼亚) regionCode="us-east4";;
		美西-俄勒冈州) regionCode="us-west1";;
		美西-洛杉矶) regionCode="us-west2";;
		芬兰) regionCode="europe-north1";;
		比利时) regionCode="europe-west1";;
		伦敦) regionCode="europe-west2";;
		法兰克福) regionCode="europe-west3";;
		荷兰) regionCode="europe-west4";;
		苏黎世) regionCode="europe-west6";;
	esac
	break
done
echo
echo -e "\e[1;32m你选择的国家/地区是\e[0m\e[1;42m $regionName（$regionCode）\e[0m"
echo
echo
echo


echo -e "\e[1;43m正在罗列 $regionName 的数据中心……\e[0m"
zoneList=$(gcloud compute zones list --filter="name:$regionCode*" | awk '!/NAME/{ print $1}')
export PS3=$'\e[1;43m你想使用哪一个数据中心？请输入数字并回车： \e[0m'
select zoneOption in $zoneList
do
	case $zoneOption in
		*) zoneName=$zoneOption
	esac
	break
done
echo
echo -e "\e[1;33m你选择的数据中心是\e[0m\e[1;43m $zoneName \e[0m"
echo
echo
echo

echo -e "\e[1;44m正在罗列当前项目正常运行的实例……\e[0m"
gcloud compute instances list | awk '!/NAME/ && /RUNNING/ { print $1 "\t" $2 "\t" $7}'|sort -k1 -rn
echo
echo
read -p $'\e[1;44m请输入新实例的名字: \e[0m' instanceNumber
instanceName="$instanceNumber"


echo -e "您即将在\e[1;31m $projectName \e[0m项目中创建一个实例，
它将位于\e[1;32m $regionName \e[0m的\e[1;33m $zoneName \e[0m数据中心，
名字叫\e[1;34m $instanceName \e[0m。
可以继续吗？"
export PS3=$'\e[1;43m请输入数字并回车： \e[0m'
select yesOrNo in $'\e[1;32m 没问题，继续 \e[0m' $'\e[1;31m 算了，放弃 \e[0m'
do
	case $yesOrNo in
		$'\e[1;31m 算了，放弃 \e[0m') echo "Bye~";sudo rm $buildInstanceFile;exit 0;;
	esac
	break
done


export instanceType="f1-micro"
export instanceOS="ubuntu-1804-lts"
export OSFamily="gce-uefi-images"
export tempConfigFile="tempConfigFile"

#进入项目并创建实例
gcloud compute instances create $instanceName \
--zone=$zoneName \
--machine-type=$instanceType \
--image-family=$instanceOS \
--image-project=$OSFamily


export httpRuleName="http-server"
export httpsRuleName="https-server"

gcloud compute instances add-tags $instanceName \
--zone $zoneName \
--tags $httpRuleName

gcloud compute instances add-tags $instanceName \
--zone $zoneName \
--tags $httpsRuleName
