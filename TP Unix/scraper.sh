#!/bin/bash
echo "  ___  ____  ____ ____ ____   ____  ____ "
echo " /___)/ ___)/ ___) _  |  _ \ / _  )/ ___) "
echo "|___ ( (___| |  ( ( | | | | ( (/ /| |     "
echo "(___/ \____)_|   \_||_| ||_/ \____)_|     "
echo "      /| _____________|_|                "
echo "O|===|* >________________>"
echo -e "      \|\033[1;33m@El-Harbil\033[0m "
initialisation()
{
if [ ! -f usedsites.txt ]
then
    touch usedsites.txt NULL.txt NULL01.txt NULL02.txt NULL03.txt reduitpourj.txt reduit.txt reduitj.txt	htmlpremiere.txt htmlallocine.txt htmltelerama.txt htmlsenscritique.txt lienversbandeannonce.txt notcurl.txt
fi
}
helper(){
	echo "Utilisation du script :"
	echo "-i                   : Initialisation"
 	echo "-c                   : Effacement des téléchargements précédents"
	echo "-e		    : Effacement des analyses précédentes"
	echo "-t date site         : Téléchargement des pages web décrivant les nouveautés de la semaine donnée par date. Si site est '-' alors on télécharge tous les sites, sinon uniquement le site demandé. Un site peut être soit un nom simple qui représente de façon unique un site web de référence alors il faut utiliser l'URL de ce site, soit un nombre alors c'est le numéro d'ordre dans les URL données plus loin dans le sujet"
	echo "-s date site         : Cette option marche comme t mais remplace l'URL officielle pour atteindre un site local qui héberge les pages précédemment téléchargées. Cette option simule un téléchargement réel"
	echo "-a                   : Analyse des fichiers préalablement téléchargés. Remarque, si vous avez extrait tous les fichiers vous analysez tous les fichiers, si vous n'avez extrait qu'un site vous n'analysez que celui-ci. Vous pourriez aussi extraire les sorties de plusieurs semaines"
	echo "-w lien page         : Fabrication de la page web qui portera le nom page. C'est l'utilisateur qui fournit le nom avec la bonne extension. Lien permet de contrôler le nombre minimum de lien pour écrire une sortie cinéma"
	echo "-h                   : Affichage de cet aide"
}
curler()
{
if [ -f usedsites.txt ]
then 
	#p=$(($2 % 4))
	echo "$1">date.txt
	echo "$2">temp.txt;TESTER=$2
	if [[ "$2" == "-" ]]
	then sitename="all"
	elif [ "$p" = "1" ]
	then sitename="allocine"
	elif [ "$p" = "2" ]
	then sitename="premiere"
	elif [ "$p" = "3" ]
    then sitename="senscritique"
	elif [ "$p" = "4" ]
    then sitename="telerama"
	elif [[ "$2" = *allo* ]] 
	then sitename="allocine"
	elif [[ "$2" = *prem* ]]	
	then sitename="premiere"
	elif [[ "$2" = *sens* ]]
	then sitename="senscritique"
	elif [[ "$2" = *tele* ]]
	then sitename="telerama"
	else sitename=`cut -d "." -f 2 temp.txt`
	fi
	mm=`cut -d"/" -f1 date.txt`
	dd=`cut -d"/" -f2 date.txt`
	yyyy=`cut -d"/" -f3 date.txt`
	semaine=`date '+%W' --date="$yyyy/$mm/$dd"`
	if [ "$sitename" = "allocine" -o "$TESTER" = "-" ]
	then sitename="allocine"
		dateallocine=`echo "sem-$yyyy-$mm-$dd"`
		echo "http://www.allocine.fr/film/agenda/WEEK" > temp.txt	
		g=`sed "s+WEEK+$dateallocine/+g" temp.txt`
		curl --silent -A Edge $g > allocine.txt
		echo -e  "$g \n" >> usedsites.txt
	fi	
	if [ "$sitename" = "premiere" -o "$TESTER" = "-" ]
	then sitename="permiere"
		if [ $yyyy -eq "2019" ];then let "semaine++" ;fi
		datepremiere=`echo "$semaine/$yyyy"`
		echo "http://www.premiere.fr/Cinema/Films-et-seances/Sorties-Cinema/WEEK" >temp.txt
		g=`sed "s+WEEK+$datepremiere/+g" temp.txt`
		curl --silent -A edge $g > premiere.txt
		echo -e "$g \n" >> usedsites.txt
		versbandeannonce=`grep -A1 'class="panel"' premiere.txt |grep "src=" |cut -d '"' -f 10 |sed "s+//+https://+g"`
        echo "$versbandeannonce" > lienversbandeannonce.txt
		versbd=`sed 's+https+\n https+g' lienversbandeannonce.txt`
		echo "$versbd" > curlsbd.txt;grep "https" curlsbd.txt > lienbd.txt
		while read p 
		do	curl --silent -A edge $p > bande.txt
			name=`grep "<title>" bande.txt | cut -d ">" -f 2 |sed "s+</title++g"`
			echo "$p lien de ce film $name" >> urlnamesP.txt
		done < lienbd.txt
	fi
	if [ "$sitename" = "senscritique" -o "$TESTER" = "-" ]
	then sitename="senscritique"
		if [ $semaine -lt "10" ];then datesenscritique=`echo "$yyyy/semaine/0$semaine"`
		else datesenscritique=`echo "$yyyy/semaine/$semaine"` ;fi
		echo "https://www.senscritique.com/films/sorties-cinema/WEEK" > temp.txt
        g=`sed "s+WEEK+$datesenscritique+g" temp.txt`
        curl --silent -A Edge $g > senscritique.txt
		echo -e "$g \n" >> usedsites.txt
		acurl=`sed -n "/eipa-interface eipa-bottom/,/d-grid-aside/p" senscritique.txt|sed 's+href="+#+g' |sed 's+" class+#+g' |cut -d "#" -f 2 |grep -E "^/"`
		echo "$g" > notcurl.txt
		for i in $acurl
		do
			exist=`grep -E "$i" notcurl.txt`
			echo "$i" >curl.txt
			if [ "$acurl" != "$exist" ] 
			then
			site=`sed "s+$i+https://www.senscritique.com$i+g" curl.txt`
			curl --silent -A Edge $site>>senscritique.txt
			echo -e "$acurl\n" >>notcurl.txt
		fi
		done
	fi
	if [ "$sitename" = "telerama" -o "$TESTER" = "-" ]
	then sitename="telerama"
		datetelerama=`echo "$dd/$mm/$yyyy"`
		echo "https://www.telerama.fr/cine/film_datesortie.php?when%5Bdate%5D=WEEK" > temp.txt
        g=`sed "s+WEEK+$datetelerama+g" temp.txt`
		echo "$g">>usedsites.txt
		i=0
        while true ;do
            phpsites="$g&page=$i"
            isit=`curl --silent -A edge $phpsites`
            echo "$isit" >thisone.txt
            grep -E "Désolé" thisone.txt > NULL.txt
            if [ "`cut -c 10 NULL.txt`" = "D" ]
                then
                    break
                else
                    echo "$isit" >>telerama.txt
    fi
    let "i++"
    done
	fi
fi		
}
hoster()
{
if [ -f usedsites.txt ]
then
	#p=$(($2 % 4))
	echo "$1">date.txt
	echo "$2">temp.txt;TESTER=$2
	if [[ "$2" == "-" ]]
	then sitename="all"
	elif [ "$p" = "1" ]
	then sitename="allocine"
	elif [ "$p" = "2" ]
	then sitename="premiere"
	elif [ "$p" = "3" ]
    then sitename="senscritique"
	elif [ "$p" = "4" ]
    then sitename="telerama"
	elif [[ "$2" = *allo* ]] 
	then sitename="allocine"
	elif [[ "$2" = *prem* ]]	
	then sitename="premiere"
	elif [[ "$2" = *sens* ]]
	then sitename="senscritique"
	elif [[ "$2" = *tele* ]]
	then sitename="telerama"
	else sitename=`cut -d "." -f 2 temp.txt`
	fi
	mm=`cut -d"/" -f1 date.txt`
	dd=`cut -d"/" -f2 date.txt`
	yyyy=`cut -d"/" -f3 date.txt`
	semaine=`date '+%W' --date="$yyyy/$mm/$dd"`
	if [ "$sitename" = "allocine" -o "$TESTER" = "-" ]
	then sitename="allocine"
		dateallocine=`echo "sem-$yyyy-$mm-$dd"`
		echo "http://www.allocine.fr/film/agenda/WEEK" > temp.txt	
		g=`sed "s/WEEK/$dateallocine/g" temp.txt|sed "s+http://+http://localhost/+g;s+https://+http://localhost/+g"`
		curl --silent -A Edge $g > allocine.txt
		echo -e  "$g \n" >> usedsites.txt
	fi	
	if [ "$sitename" = "premiere" -o "$TESTER" = "-" ]
	then sitename="permiere"
		datepremiere=`echo "$semaine/$yyyy"`
		echo "http://www.premiere.fr/Cinema/Films-et-seances/Sorties-Cinema/WEEK" >temp.txt
         g=`sed "s+WEEK+$datepremiere+g" temp.txt|sed "s+http://+http://localhost/+g;s+https://+http://localhost/+g"`
		curl --silent -A edge $g > premiere.txt
		echo -e "$g \n" >> usedsites.txt
		versbandeannonce=`grep -E "Bandes-annonces" premiere.txt |sed  "s/href=/#/g" |cut -d "#" -f 2  |cut -d'"' -f 2 |grep -E "/film/" |sed 's+/film+http://www.premiere.fr/film+g' |sed "s+/bandes-annonces++g" `
        echo "$versbandeannonce" > lienversbandeannonce.txt
		versbd=`sed "s+http://+\n http://localhost/+g;s+https://+\n http://localhost/+g" lienversbandeannonce.txt`
		echo "$versbd" > curlsbd.txt
        curl --silent -A edge $versbd >> forbandefinale.txt
        lienbande=`grep -E 'allowfullscreen="allowfullscreen"' forbandefinale.txt |sed 's+src="//+#+g' |sed 's+"></iframe>+#+g' | cut -d"#" -f2 NULL.txt`
        echo "$lienbande" > lienbd00.txt
	fi
	if [ "$sitename" = "senscritique" -o "$TESTER" = "-" ]
	then  sitename="senscritique"
		if [ $semaine -lt "10" ];then datesenscritique=`echo "$yyyy/semaine/0$semaine"`
		else datesenscritique=`echo "$yyyy/semaine/$semaine"` ;fi
		echo "https://www.senscritique.com/films/sorties-cinema/WEEK" > temp.txt
		g=`sed "s+WEEK+$datesenscritique+g" temp.txt |sed "s+http://+http://localhost/+g;s+https://+http://localhost/+g" `
        curl --silent -A Edge $g > senscritique.txt
		echo -e "$g \n" >> usedsites.txt
		acurl=`sed -n "/eipa-interface eipa-bottom/,/d-grid-aside/p" senscritique.txt|sed 's+href="+#+g' |sed 's+" class+#+g' |cut -d "#" -f 2 |grep -E "^/"`
		echo "$g" > notcurl.txt
		for i in $acurl
		do
			exist=`grep -E "$i" notcurl.txt`
			echo "$i" >curl.txt
			if [ "$acurl" != "$exist" ] 
			then
				site=`sed "s+$i+http://localhost/www.senscritique.com$i+g" curl.txt`
				curl --silent -A Edge $site>>senscritique.txt
			      	echo -e "$acurl\n" >>notcurl.txt
		fi
		done
	fi
	if [ "$sitename" = "telerama" -o "$TESTER" = "-" ]
	then sitename="telerama"
		datetelerama=`echo "$dd/$mm/$yyyy"`
		echo "https://www.telerama.fr/cine/film_datesortie.php?when%5Bdate%5D=WEEK" > temp.txt
        g=`sed "s+WEEK+$datetelerama+g" temp.txt|sed "s+http://+http://localhost/+g;s+https://+http://localhost/+g" `
		echo "$g">>usedsites.txt
		i=0
                while true ;do
                        phpsites="$g&page=$i"
                        isit=`curl --silent -A edge $phpsites`
                        echo "$isit" >thisone.txt
                        grep -E "Désolé" thisone.txt > NULL.txt
                        if [ "`cut -c 10 NULL.txt`" = "D" ]
                        then
                                break
                        else
                                echo "$isit" >>telerama.txt
                        fi
                        let "i++"
                done
	fi
fi	
}
deleter()
{	
rm -f allocine.txt telerama.txt senscritique.txt premiere.txt
}
eraser()
{
rm -f htmlpremiere.txt htmlallocine.txt htmltelerama.txt htmlsenscritique.txt
}
analyser()
{
if [ -f usedsites.txt ]
then grep -E "http" usedsites.txt > NULL.txt;sitename=`cut -d"." -f2 NULL.txt`
	for name in $sitename
	do
	if [ "$name" = "allocine" ]
	then titre=`grep -F "meta-title-link" allocine.txt |sed 's+.html">+^+g' |cut -d"^" -f2 |cut -d"<" -f1`
		ffnameonpic=`grep -E 'src="' allocine.txt |sed 's/" src="http/data-src="http/g' |sed "s/data-src=/^/g" |sed 's/" width/^/g' |cut -d "^" -f2 |sed "s/#//g" |sed 's/alt="/#alt=/g' |cut -d "#" -f2 |sed 's/alt=//g' |sed "s/^Bande-annonce//g" |sed 's/^[ ]//g' |sed "s/ /#€#/g" |sed "s/&039;/'/g"`
		allocine=`sed "s+&#039;+'+g" allocine.txt`
		echo "$titre"  > NULL.txt
		newtitle=`sed "s/ /#€#/g" NULL.txt|sed "s/&#039;/'/g"`
		echo "$allocine" >allocine.txt
		for i in $ffnameonpic
		do
			for j in $newtitle
			do
				if [ "$i" = "$j" ]
				then picdei=`grep -E 'src="' allocine.txt |sed 's/" src="http/data-src="http/g' |sed "s/data-src=/^/g" |sed 's/" width/^/g' |cut -d "^" -f2 |sed 's/alt="/#alt=/g' |sed "s/ /#€#/g" |sed "s/&#039;/'/g" |grep "$i" |cut -d "#" -f1 `
					echo $i >NULL.txt
					k=`sed "s+#€#+ +g" NULL.txt|sed "s+   + +g" |sed "s+  + +g"`
					notepresse=`sed -n "/>$k</,/thumbnail /p" allocine.txt |sed -n '/Presse/,/span></p' |sed "s+</span></div>+#+g" |grep -E "#" | cut -d "#" -f1`
					notespec=`sed -n "/>$k</,/thumbnail /p" allocine.txt |sed -n '/Spectateurs/,/span></p' |sed "s+</span></div>+#+g" |grep -E "#"|cut -d "#" -f1`
					syno=`sed -n "/>$k</,/thumbnail /p" allocine.txt |sed -n '/content-txt /,/div>/p' |sed 's+<div class="content-txt ">++g' |sed 's+</div>++g' |tr -s ' '|sort |grep "[0-9a-zA-Z]"`
		 			echo -e "<h2>$k:</h2><ul><li>SYNOPSIS:$syno</li><li>note Spectateurs:$notespec</li><li>note Presse:$notepresse</li><img src=$picdei></li></ul>\n" >>htmlallocine.txt
				fi
			done
		done
		grep "^[<h2>]" htmlallocine.txt>NULL.txt;cat NULL.txt>htmlallocine.txt
	fi
	if [ "$name" = "premiere" ]
	then npptitreV=`grep "lien de ce film Dailymotion Video Player" urlnamesP.txt| cut -d "-" -f 2`
		www=1
		for j in $npptitreV
		do
			echo "$j">NULL.txt
			spacename=`sed "s+€+ +g" NULL.txt|sed "s+'+#039;+g"`
			reduitpourj=`sed -n "/>$spacename/,/header>/p" reduit.txt`
			echo "$reduitpourj" > reduitpourj.txt
			lienbd=`grep -E 'allowfullscreen="allowfullscreen" src="' reduitpourj.txt|sed 's+allowfullscreen="allowfullscreen" src="//www+#http://www+g' |sed 's+"></iframe>+#+g' |cut -d "#" -f 2`
			ninternaute=`sed -n '/>internautes</,/<div class="rating">/p' reduitpourj.txt | sed 's+<span class="rating-value">+#+g' |sed "s+</span>+#+g" | cut -d "#" -f 2 |sed -n '/<br /,/</p' |grep -E "(avis)"`
			sed -i "s+&#039;+#039;+g" reduit.txt
			sed 's+["/]+-+g' reduit.txt > reduitj.txt
			grep -B 3  "<li class=-active->$spacename<-li>" reduitj.txt>>NULL02.txt
			genre=`sed 's+<span property=-name->+€+g' NULL02.txt > NULL01.txt ;sed 's+<-span><-a>+€+g' NULL01.txt>NULL.txt;grep -E "€" NULL.txt>NULL01.txt;sed "s+€+^+g" NULL01.txt>NULL.txt;cut -d "^" -f 2 NULL.txt`
			echo "$genre" |uniq > NULL01.txt
			genre=`sed -n "$www p" NULL01.txt`
			ninternaute=`echo "$ninternaute" |uniq |tr -d '\n'`
			lienbd=`echo "$lienbd" |uniq`
			sed -i '0,/<meta property="position" content="2" /s/<meta property="position" content="2" /Done/' reduit.txt
			echo -e "<h2>$spacename:</h2><ul><li>GENRE:$genre</li><li>note internaute:$ninternaute</li><li align='center'><iframe width='300' height='300' src='$lienbd' frameborder='0' allow='accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture' allowfullscreen></iframe></li></ul>\n">> htmlpremiere.txt	
			uniq htmlpremiere.txt >NULL.txt
			cat NULL.txt > htmlpremiere.txt;let www++
		done						
	fi     			
	if [ "$name" = "telerama" ]
	then	titre=`grep -E 'href="/cinema/films' telerama.txt|cut -d ">" -f2 |cut -d "<" -f1 |sed "s/ /%%/g"`
		echo "$titre">titretelerama.txt
		for j in $titre
		do
			echo "$j">title.txt
			newtitle=`sed "s/%%/ /g" title.txt`
			sed -n "/>$newtitle</,/item--title/p" telerama.txt >reduitj.txt
			Realise=`grep  -E "Réalisé par :" reduitj.txt|sed 's+itemprop="name">+#+g'|sed "s+</span>+#+g" |cut -d "#" -f 2`
			genre=`grep -E 'itemprop="genre"' reduitj.txt | sed 's+<span itemprop="genre">+#+g' | sed "s+</span>+#+g" | cut -d "#" -f 2 |uniq`
			Avec=`grep -E "Avec" reduitj.txt>NULL01.txt;sed 's+<span itemprop="name">+\n#+g' -i NULL01.txt;sed "s+</span></a>+#\n,+g" -i NULL01.txt;grep -E "^[#]" NULL01.txt>NULL.txt;cut -d "#" -f 2 NULL.txt>NULL02.txt;uniq NULL02.txt`
			Role=`grep -E "^[, (]" NULL01.txt|cut -d "," -f 2 |sed "s/ (/#(/g" |sed "s+)+)#+g" |grep "^[#]" |cut -d "#" -f 2 |uniq > NULL01.txt`
			avecrole=`paste NULL02.txt NULL01.txt > NULL.txt;perl -p -0n -e 's/\n/, /g' NULL.txt`
			echo -e "<h2>$newtitle:</h2><ul><li>GENRE:$genre</li><li>Realisateur:$Realise</li><li>Acteurs(Role):$avecrole</li></ul>\n">> htmltelerama.txt				 	
		done
	fi
	if [ "$name" = "senscritique" ]
	then title=`sed -n '/class="d-heading2 elco-title">/,/a>/p' senscritique.txt |grep -E "href=" |sed 's+">+^+g' |sed 's+</a>+^+g' |cut -d "^" -f 2 |sed "s/ /%%/g"`
		for j in $title
		do
			echo "$j">title.txt
			newtitle=`sed "s/%%/ /g" title.txt`
			sed -n "/>$newtitle</,/elpr-item/p" senscritique.txt>reduitj.txt
			sortie=`grep -E "Sortie : <time" reduitj.txt|sed "s+ >+#+g" |sed "s+</time>+#+g" |cut -d "#" -f 2 `
			duree=`grep -E 'class="eins-sprite eins-clock  elco-clock' reduitj.txt|sed 's+/span>+#+g' |cut -d "#" -f 2`
			realisateur=`grep -E 'class="elco-baseline-a"' reduitj.txt|sed 's+class="elco-baseline-a">+#+g' |sed 's+</a>+#+g' |cut -d "#" -f2 `
			notes=`sed -n '/title="Note globale pondérée/,/</p' reduitj.txt|sed "s+</a>++g" |sed "s+\t++g" |sed 's+title="++g' |sed 's+">++g' |perl -p -0n -e 's/\n/ /g'`
			echo -e "<h2>$newtitle:</h2><ul><li>Durée:$duree</li><li>Realisateur:$realisateur</li><li>Date de Sotie:$sortie</li><li>$notes</p></ul>\n">> htmlsenscritique.txt
		done	
	fi
	done
fi
}
webcreateur()
{	rm -f $2 NULL02.txt NULL03.txt names.txt;touch $2 NULL02.txt NULL03.txt names.txt
	sort usedsites.txt|grep "^h">NULL.txt;cat NULL.txt>usedsites.txt
	vvt=`echo -e '<!DOCTYPE html">\n<html lang="fr">\n<head>\n<meta charset="utf-8" />\n<title>Sami"s.script</title>\n</head>\n<body>\n<div id="conteneur">\n<div id="contenu">'`
	i=$1
	if [ "$1" -ge "4" -o "$1" -eq "1" ]
	then
		i=4
	fi
	while [ "$i" -ge "1" ];do
		sitename=`sed -n "$i p" usedsites.txt |cut -d"." -f2 `
		Lsite=`echo -e "html$sitename.txt"|grep -E "."`
		cat $Lsite >> $2
	    i=$(( $i - 1 ))
	done
	if [ $1 -eq "1" ]
	then 
		uniq $2>NULL01.txt;sed "s+#039;+'+g" -i NULL01.txt;sed "s+&++g" -i NULL01.txt;sed "s+,++g" -i NULL01.txt;grep -e "^[<h2>]" NULL01.txt > $2 ;echo "Done creating $2";exit 0
	fi
	uniq $2>NULL01.txt;sed "s+#039;+'+g" -i NULL01.txt;sed "s+&++g" -i NULL01.txt;sed "s+,++g" -i NULL01.txt;sed "s+ô+o+g" -i NULL01.txt;sed "s+[éèê]+e+g" -i NULL01.txt;grep -e "^[<h2>]" NULL01.txt > $2
	titreall=`cut -d ">" -f 2 $2 |grep -e "</h2" |sed "s+ô+o+g" |sed "s+[éèê]+e+g" |cut -d ":" -f1 |sed 's/\s\+$//' |sort |uniq --repeated -i -w 5 |sed "s+&#039;+'+g" |sed "s+ +€+g"`
	for j in $titreall
	do	spacename=`echo "$j">NULL.txt;sed "s+€+ +g" NULL.txt|sed "s+A+A+g"|sed "s+[éèê]+e+g"|sed "s+[:-;/*+]++g"`;echo "$spacename" >NULL01.txt;Range=${#spacename};if [ $Range -ge 4 ] ;then Range=$(($Range - $Range/3));k=`cut -c1-$Range NULL01.txt`;else k=$j;fi;
		titrevalable=`grep -i "$k" $2 |sed "s+[:-]++g"|cut -d "<"  -f2| sed "s+h2>++g"|grep -i "$k"|uniq -i -c4|tr -d " "|cut -c1`
		if [ $titrevalable = "$1" ] 2> /dev/null
		then echo "$j" >> names.txt;fi
	done
	while read p
	do  echo $p>NULL.txt;spacename=`sed "s+€+ +g" NULL.txt|sed "s+A+A+g"`;echo "$spacename" >NULL01.txt;Range=${#spacename};if [ $Range -ge 4 ] ;then Range=$(($Range - $Range/3));k=`cut -c1-$Range NULL01.txt`;else k=$p;fi; grep -e ".jpg" $2 > NULL.txt
		if [ -s NULL.txt ]
		then  grep -i -e "<h2>$k" $2 > NULL.txt;sed "s+<h2>.*</h2>++g" NULL.txt>NULL01.txt 2> /dev/null ;tr -d '\n' < NULL01.txt > NULL02.txt;sed "s+<h2>+\n<h2>+g" NULL02.txt> NULL01.txt;sed  -i "s+^<ul>+<h2>$spacename:</h2><ul>+g" NULL01.txt;cat NULL01.txt > temp.txt;lienbd=`grep "$k" NULL.txt|sed "s+src='+^+g" |sed "s+' frame+^+g" 2> /dev/null|cut -d "^" -f 2 |grep -e "^[a-z0-9A-Z]"`;sed "s+`echo $lienbd`++g" -i temp.txt 2> /dev/null;sed "s+' frameborder='0' allow='accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture' allowfullscreen></iframe></li>++g" -i temp.txt  2> /dev/null;sed "s+<li align='center'><iframe width='300' height='300' src='++g" -i temp.txt 2> /dev/null;sed 's+<img+<a href=><img+g' -i temp.txt  2> /dev/null;sed "s+href=+href='`echo $lienbd`'+g" -i temp.txt  2> /dev/null; sed "s+</li></ul>+</a></li></ul></ul>+g" -i temp.txt  2> /dev/null;sed "s+$+\n+g" temp.txt >> NULL03.txt
		else  grep -i -e "$k" $2 |sort |uniq >NULL01.txt;sed -i  "s+<h2>.*</h2>++g" NULL01.txt 2> /dev/null;tr -d '\n' < NULL01.txt > NULL.txt;sed "s+<h2>+\n<h2>+g" NULL.txt> NULL01.txt;sed -i "s+^<ul>+<h2>$spacename:</h2><ul>+g" NULL01.txt;sort NULL01.txt|uniq >> NULL03.txt
		fi;done < names.txt	
	echo "$vvt" >$2;uniq NULL03.txt|sed "s+#039;+'+g" >>$2;rm -f usedsites.txt;touch usedsites.txt
	echo "Done creating $2"
}
while [ "$#" -ge "1" ] ; do
case "$1" in
    -i) initialisation 
	shift 1;; 
	-h) helper
	shift 1;;	
	-t) curler $2 $3
	shift 3;;	
	-c) deleter
	shift 1;;
	-e) eraser
	shift 1;;
	-s) hoster $2 $3
	shift 3;;
	-a) analyser
	shift 1;;
	-w) webcreateur $2 $3 
	shift 3;;
	*) echo "ERROR IN INPUT TRY -h FOR MORE HELP"
    exit 0;;
	esac 
done