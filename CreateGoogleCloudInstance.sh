#!/bin/bash

source <(curl -s https://raw.githubusercontent.com/killDevils/AutoLAMP/master/source.sh)

gcloud config set project defaultdefault

echo -e "\e[1;41m Listing projects...\e[0m"
projectList=$(gcloud projects list | awk '!/NAME/{ print $1}')
export PS3=$'\e[1;41m Which Project do you wanna use? Enter the number and press return: \e[0m'
select projectOption in $projectList
do
	case $projectOption in
		*) projectName=$projectOption
	esac
	break
done
echo
echo -e "\e[1;31m The project you chose is: \e[0m\e[1;41m $projectName \e[0m"
gcloud config set project $projectName
echo
echo
echo

echo -e "\e[1;42m Listing country or region...\e[0m"
export PS3=$'\e[1;42m Which country or region do you wanna select? Enter the number and press return:  \e[0m'
select regionName in "Hong_Kong" "Taiwan" "Tokyo" "Osaka" "Mumbai" "Singapore" "Sydney" "Montreal" "Sao_Paulo" "Iowa" "South_Carolina" "North_Virginia" "Oregon" "Los_Angeles" "Finland" "Belgium" "London" "Frankfurt" "Netherlands" "Zurich"
do
	case $regionName in
		Hong_Kong) regionCode="asia-east2";;
		Taiwan) regionCode="asia-east1";;
		Tokyo) regionCode="asia-northeast1";;
		Osaka) regionCode="asia-northeast2";;
		Mumbai) regionCode="asia-south1";;
		Singapore) regionCode="asia-southeast1";;
		Sydney) regionCode="australia-southeast1";;
		Montreal) regionCode="northamerica-northeast1";;
		Sao_Paulo) regionCode="southamerica-east1";;
		Iowa) regionCode="us-central1";;
		South_Carolina) regionCode="us-east1";;
		North_Virginia) regionCode="us-east4";;
		Oregon) regionCode="us-west1";;
		Los_Angeles) regionCode="us-west2";;
		Finland) regionCode="europe-north1";;
		Belgium) regionCode="europe-west1";;
		London) regionCode="europe-west2";;
		Frankfurt) regionCode="europe-west3";;
		Netherlands) regionCode="europe-west4";;
		Zurich) regionCode="europe-west6";;
	esac
	break
done
echo
echo -e "\e[1;32m The country or region you chose is \e[0m\e[1;42m $regionName（$regionCode）\e[0m"
echo
echo
echo


echo -e "\e[1;43m Listing data center in $regionName...\e[0m"
zoneList=$(gcloud compute zones list --filter="name:$regionCode*" | awk '!/NAME/{ print $1}')
export PS3=$'\e[1;43m Which data center do you wanna use? Enter the number and press return:  \e[0m'
select zoneOption in $zoneList
do
	case $zoneOption in
		*) zoneName=$zoneOption
	esac
	break
done
echo
echo -e "\e[1;33m The data center you chose is: \e[0m\e[1;43m $zoneName \e[0m"
echo
echo
echo


echo -e "\e[1;42m Listing Instance Type...\e[0m"
export PS3=$'\e[1;42m Which Instance Type do you wanna select? Enter the number and press return:  \e[0m'
select type in "f1-micro_1vCPU_0.6GB" "g1-small_1vCPU_1.7GB" "n1-standard-1_1vCPU_3.75GB"
do
	case $type in
		f1-micro_1vCPU_0.6GB) machineType="f1-micro";;
		g1-small_1vCPU_1.7GB) machineType="g1-small";;
		n1-standard-1_1vCPU_3.75GB) machineType="n1-standard-1";;

	esac
	break
done
echo
echo -e "\e[1;32m The Instance Type you chose is \e[0m\e[1;42m $machineType \e[0m"
echo
echo
echo



echo -e "\e[1;44m Listing running instances in this project...\e[0m"
gcloud compute instances list | awk '!/NAME/ && /RUNNING/ { print $1 "\t" $2 "\t" $7}'|sort -k1 -rn
echo
echo
read -p $'\e[1;44m Type in the name for this instance: \e[0m' instanceNumber
instanceName="$instanceNumber"


echo -e "You are gonna build an instance in \e[1;31m $projectName \e[0m,
it will locate in \e[1;33m $zoneName \e[0m data center of \e[1;32m $regionName \e[0m ，
its name is \e[1;34m $instanceName \e[0m.
Continue?"
export PS3=$'\e[1;43m Enter the number and press return: \e[0m'
select yesOrNo in $'\e[1;32m No problem, go on \e[0m' $'\e[1;31m Nope, cancel \e[0m'
do
	case $yesOrNo in
		$'\e[1;31m Nope, cancel \e[0m') echo "Bye~";sudo rm $buildInstanceFile;exit 0;;
	esac
	break
done


export instanceType=$machineType
export instanceOS="ubuntu-1804-lts"
export OSFamily="gce-uefi-images"
export tempConfigFile="tempConfigFile"

insSetupFilePath="/home/naidaomeihui/setup.sh"

echo '#!/bin/bash' > startup-script.sh
echo "
insSetupFile=\"ubuntu_18.04.sh\"
curl -s -O https://raw.githubusercontent.com/killDevils/AutoLAMP/master/$insSetupFile
mv $insSetupFile $insSetupFilePath
sudo chmod a+x $insSetupFilePath
" >> startup-script.sh



gcloud compute instances create $instanceName \
--zone=$zoneName \
--machine-type=$instanceType \
--image-family=$instanceOS \
--image-project=$OSFamily \
--metadata-from-file startup-script=startup-script.sh



judgeHttpAndHttps

gcloud compute instances add-tags $instanceName \
--zone $zoneName \
--tags $httpRuleTag

gcloud compute instances add-tags $instanceName \
--zone $zoneName \
--tags $httpsRuleTag

gcloud compute instances remove-metadata --project $projectName --zone $zoneName $instanceName \
      --all
rm -f startup-script.sh
rm -f firewallRulesTempList

cecho $yellow "Instance is up, entering it..."
cecho $purple "Please run \"bash $insSetupFilePath\" in the instance"

gcloud compute ssh --project $projectName --zone $zoneName $instanceName
while [ $? -ne 0 ]; do
	gcloud compute ssh --project $projectName --zone $zoneName $instanceName
	sleep 5
done


######### DEBUG

projectName=testmybrain
zoneName=asia-east2-b
instanceName=testweb03
gcloud compute ssh --project $projectName --zone $zoneName $instanceName
echo $?

while [ $? -ne 0 ]; do
	gcloud compute ssh --project $projectName --zone $zoneName $instanceName
	sleep 5
done



# ufwDelete(){
# 	gcloud compute firewall-rules delete $1
# }
#
#
# if [ -z "$httpExistOrNot" ]; then
# 	echo "http Not Exist"
# else
# 	echo "http is here!"
# fi
#
# if [ -z "$httpsExistOrNot" ]; then
# 	echo "https Not Exist"
# else
# 	echo "https is here!"
# fi
#
# newFunc(){
# 	tyughj="123tyughj"
# }
# newFunc
# echo $tyughj
