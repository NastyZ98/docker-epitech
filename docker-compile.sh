#!/bin/bash

function checkVersion() {
        version=$(curl -s https://raw.githubusercontent.com/NastyZ98/docker-epitech/master/version | head -n 1 )
        if [ "$version" != "1.4" ]; then
                echo -e "\e[1m\e[32m[+] \e[39mUpdating ..."
                sudo curl -o docker-compile.tmp https://raw.githubusercontent.com/NastyZ98/docker-epitech/master/docker-compile.sh
                sudo mv $0 docker-compile.old
                sudo mv docker-compile.tmp docker-compile
                sudo rm -f docker-compile.old
                sudo chmod +x docker-compile
                sudo mv docker-compile ~/bin/
                if [ -e /usr/bin/docker-compile.sh ]
                then
	                echo "Delete old location"
	                sudo rm -f /usr/bin/docker-compile.sh
                fi
                echo -e "\e[1m\e[32m[+] \e[39mDone restart script"
                exit
        fi
}

function display_help() {
        echo -e "\e[1m\e[21mUSAGE : \n\t" $0 " [PATH] [FLAG] [OPTION]"
        echo -e "FLAGS :"
        echo -e "\t--make               Compile project"
        echo -e "OPTIONS :"
        echo -e "\t--valgrind           Start valgrind after compilation"
        echo -e "\t--interactive        Start project"
        exit
}

function copyWorkspace() {
        sudo docker cp $1 epi:/home/compilation/
}

function startContainer() {
        sudo docker container run -d -t --name epi epitechcontent/epitest-docker bash &> /dev/null
        copyWorkspace $1
}

function deleteContainer() {
        sudo docker container rm -f epi &> /dev/null
}

function compileProject() {
        sudo docker container exec epi bash -c "cd /home/compilation/ && make"
        if [ $? != 0 ]; then
                echo -e "\n\e[31m/!\ BUILD FAIL\e[39m"
        else
                echo -e "\n\e[92m[+] BUILD COMPLETE\e[39m"
        fi
}

function checkImageExist() {

        image=$(sudo docker images -f "reference=epitechcontent/epitest-docker" --format "{{.Repository}}")

        if [ -z "$image" ]; then
                echo -e "\e[1m\e[32m[+]\e[39m Image not found locally, it will be dowloaded from the Hub"
                sudo docker pull epitechcontent/epitest-docker
                startContainer $1
                compileProject
                deleteContainer
        else
                echo -e "\e[1m\e[32m[+]\e[39m Image found locally"
                echo -e "Copy file from host to container ..."
                startContainer $1
                compileProject
                deleteContainer
        fi
}

if [ $# -eq 0 ]; then
        checkVersion
        display_help
        exit
fi

if [ ! -z $1 ] && [ $2 == "--make" ]; then
        checkVersion
        checkImageExist $1
        deleteContainer
else
        checkVersion
        display_help
        exit
fi