#!/bin/bash

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
select regionName in "Hong Kong" "Taiwan" "Tokyo" "Osaka" "Mumbai" "Singapore" "Sydney" "Montreal" "Sao Paulo" "Iowa" "South Carolina" "North Virginia" "Oregon" "Los Angeles" "Finland" "Belgium" "London" "Frankfurt" "Netherlands" "Zurich"
do
	case $regionName in
		Hong Kong) regionCode="asia-east2";;
		Taiwan) regionCode="asia-east1";;
		Tokyo) regionCode="asia-northeast1";;
		Osaka) regionCode="asia-northeast2";;
		Mumbai) regionCode="asia-south1";;
		Singapore) regionCode="asia-southeast1";;
		Sydney) regionCode="australia-southeast1";;
		Montreal) regionCode="northamerica-northeast1";;
		Sao Paulo) regionCode="southamerica-east1";;
		Iowa) regionCode="us-central1";;
		South Carolina) regionCode="us-east1";;
		North Virginia) regionCode="us-east4";;
		Oregon) regionCode="us-west1";;
		Los Angeles) regionCode="us-west2";;
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


export instanceType="f1-micro"
export instanceOS="ubuntu-1804-lts"
export OSFamily="gce-uefi-images"
export tempConfigFile="tempConfigFile"

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
