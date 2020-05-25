# paste the line below to source online
# source <(curl -s -O https://raw.githubusercontent.com/killDevils/AutoLAMP/master/source.sh)



grey='1;38;5;248';white='1;97';red='1;31';green='1;32';yellow='1;33';blue='1;34';purple='1;35';cyan='1;36';greyBlink='1;38;5;248;5';whiteBlink='1;97;5';redBlink='1;31;5';greenBlink='1;32;5';yellowBlink='1;33;5';blueBlink='1;34;5';purpleBlink='1;35;5';cyanBlink='1;36;5';whiteGrey='1;37;100';whiteRed='1;37;41';whiteGreen='1;37;42';whiteYellow='1;37;43';whiteBlue='1;37;44';whitePurple='1;37;45';whiteCyan='1;37;46';whiteGreyBlink='1;37;100;5';whiteRedBlink='1;37;41;5';whiteGreenBlink='1;37;42;5';whiteYellowBlink='1;37;43;5';whiteBlueBlink='1;37;44;5';whitePurpleBlink='1;37;45;5';whiteCyanBlink='1;37;46;5';

cecho(){
  echo -e "\e[$1m $2 \e[0m"
}

cstr(){
  echo -ne "\e[$1m$2\e[0m"
}

CatCurBytes(){
  echo $(cat /sys/class/net/ens4/statistics/tx_bytes)
}

Seconds2TimeInterval (){
  T=$1
  D=$((T/60/60/24))
  H=$((T/60/60%24))
  M=$((T/60%60))
  S=$((T%60))

  if [[ ${D} = 0 ]] && [[ ${H} = 0 ]]; then
    if [[ ${M} -lt 10 ]]; then
      printf '%d分钟' $M
    else
      printf '%02d分钟' $M
    fi
  elif [[ ${D} = 0 ]]; then
    if [[ ${H} -lt 10 ]]; then
      printf '%d小时%02d分钟' $H $M
    else
      printf '%02d小时%02d分钟' $H $M
    fi
  else
    printf '%d天%02d小时%02d分钟' $D $H $M
  fi
}

Days2Seconds(){
  printf %.0f $(echo "$1*24*3600" | bc -l)
}

GB2Bytes(){
  printf %.0f $(echo "$1*1024*1024*1024" | bc -l)
}

Bytes2GB(){
  printf %.$2f $(echo "$1/1024/1024/1024" | bc -l)
}

FourOperations(){
  printf %.$2f $(echo "$1" | bc -l)
}

divider(){
	echo
	echo
	echo
}

chooseProject(){
	projectsList=$(cat $gcstkCache/projectsList)
	export PS3=$(cecho $blue "Which project?")
	select i in $projectsList
	do
		case $i in
			*) projectName=$i
		esac
		break
	done
}

chooseIns(){
  if [ -z $projectName ]; then
    chooseProject
  fi
  insList=$(cat $gcstkCache/$projectName/insList | awk '!/NAME/ && /RUNNING/ { print $1 }' | sort -k1)
  export PS3=$(cecho $purple "Which instance?")
  select i in $insList
  do
    case $i in
      *) insName=$i
    esac
    break
  done
}

chooseRegion(){
  regionsList=$(cat $gcstkCache/regionsList | awk '!/NAME/ { print $1 }')
  export PS3=$(cecho $yellow "Which region?")
  select i in $regionsList
  do
  	case $i in
  		*) regionCode=$i
  	esac
  	break
  done
}

chooseZone(){
  if [ -z $regionCode ]; then
    chooseRegion
  fi
  zonesList=$(cat $gcstkCache/regionsList | grep $regionCode | awk '{ print $1 }')
  export PS3=$(cecho $cyan "Which zone?")
  select i in $zonesList
  do
  	case $i in
  		*) zoneName=$i
  	esac
  	break
  done
}

cread(){
  read -p "$(cecho $1 "$2")" $3
}

addCron(){
  cread $green "Full path of the script: " scriptPath
  cread $blue "How do you change * * * * * : " fiveStar
  if [ ! -x "$scriptPath" ]; then
    sudo chmod a+x $scriptPath
  elif [ ! -f "$scriptPath" ]; then
    echo "File does not exist!"
    return 1
  fi
  crontab -l > tmpcron
  echo "$fiveStar $scriptPath" >> tmpcron
  crontab tmpcron
  rm tmpcron
  unset $fiveStar
  unset $scriptPath
}

deleteCron(){
  cread $green "Script Name: " scriptName
  awkContent=\'\!/$scriptName/\' # suppose to be '!/$scriptName/'
  eval "crontab -l | awk $awkContent > tmpcron"
  crontab tmpcron
  rm tmpcron
}

judgeHttpAndHttps(){
  httpRuleTag="http-server"
  httpRuleName="default-allow-http"
  httpsRuleTag="https-server"
  httpsRuleName="default-allow-https"

  gcloud compute firewall-rules list > firewallRulesTempList
  httpExistOrNot=$(cat firewallRulesTempList | grep tcp:80 | grep http)
  httpsExistOrNot=$(cat firewallRulesTempList | grep tcp:443 | grep https)
  if [ -z "$httpExistOrNot" ]; then
  	gcloud compute firewall-rules create $httpRuleName \
  	--action allow \
  	--direction ingress \
  	--rules tcp:80 \
  	--source-ranges 0.0.0.0/0 \
  	--priority 1000 \
  	--target-tags $httpRuleTag
  fi
  if [ -z "$httpsExistOrNot" ]; then
  	gcloud compute firewall-rules create $httpsRuleName \
  	--action allow \
  	--direction ingress \
  	--rules tcp:443 \
  	--source-ranges 0.0.0.0/0 \
  	--priority 1000 \
  	--target-tags $httpsRuleTag
  fi
}



#
