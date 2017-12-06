#!/bin/bash
#----------------------
# Name : script.sh
# Authors : Cloé Depardon, Etienne Blanc-Coquand, Paul-Edouard Boudier
# Utilities : Script that allows you to create and customize a Wordpress.
# Creation date : 05/12/2017
#----------------------

#----------------------
# Variables for test
# dbName=wordpress
# dbUser=root
# dbPwd=0000
# wpUrl=192.168.33.10
# wpTitle=blog
# wpUser=root
# wpPwd=0000
# wpMail=a@a.com
#----------------------

# Functions declaration
#----------------------
# THEMES
#----------------------
function addTheme {
    cd /var/www/html/
    wp theme install $1
    echo "Thème installé."
}

function deleteTheme {
    cd /var/www/html/
    wp theme delete $1
    echo "Thème supprimé."
}

function enableTheme {
    cd /var/www/html/
    wp theme activate $1
    echo "Thème activé."
}

function disableTheme {
    cd /var/www/html/
    wp theme disable $1
    echo "Thème désactivé."
}

function searchTheme {
    cd /var/www/html/
    echo "Résultats pour $1"
    wp theme search $1 --per-page=7
}

#----------------------
# PLUGINS
#----------------------
function addPlugin {
    cd /var/www/html/
    wp plugin install $1
    echo "Plugin installé."
}

function deletePlugin {
    cd /var/www/html/
    wp plugin delete $1
    echo "Plugin supprimé."
}

function enablePlugin {
    cd /var/www/html/
    wp plugin activate $1
    echo "Plugin activé."
}

function disablePlugin {
    cd /var/www/html/
    wp plugin deactivate $1
    echo "Plugin désactivé."
}

function searchPlugin {
    cd /var/www/html/
    echo "Résultats pour $1"
    wp plugin search $1 --fields=name,version,slug,rating,num_ratings
}

function reset {
    cd /var/www/html/
    wp db reset --yes
}

#----------------------
# INSTALLATION
#----------------------
function setup {
    echo "Vérification des paquets requis et installation de ceux manquants"
    sudo apt-get install -Y mysql-server apache2 php7.0 php7.0-mysql libapache2-mod-php7.0
    sudo a2enmod rewrite
    #TODO : Add SQL query to create the wordpress database
    cd /var/www/html/
    sudo rm -rf index.html
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    sudo chmod 777 wp-cli.phar
    sudo mv wp-cli.phar /usr/local/bin/wp
    wp core download
    echo "Fin du téléchargement et de l'installation des composants requis..."
    echo "Configuration de Wordpress"
    echo "Connexion à la base de données :"
    echo "Nom de la base de données (default : wordpress):"
    read -e dbName
    if [ -z "$dbName" ]
    then
        dbName="wordpress"
    fi
    echo "Utilisateur de la base de données (default : root):"
    read -e dbUser
        if [ -z "$dbUser" ]
    then
        dbUser="root"
    fi
    echo "Mot de passe (default : 0000):"
    read -s dbPwd
        if [ -z "$dbPwd" ]
    then
        dbPwd="0000"
    fi
    echo "Configuration du site Wordpress"
    echo "Adresse du site (default : 192.168.33.10):"
    read -e wpUrl
        if [ -z "$wpUrl" ]
    then
        wpUrl="192.168.33.10"
    fi
    echo "Nom du site :"
    read -e wpTitle
        if [ -z "$wpTitle" ]
    then
        wpTitle="Blog"
    fi
    echo "Identifiant administrateur (default : root):"
    read -e wpUser
        if [ -z "$wpUser" ]
    then
        wpUser="root"
    fi
    echo "Mot de passe administrateur (default : 0000):"
    read -s wpPwd
        if [ -z "$wpPwd" ]
    then
        wpPwd="0000"
    fi
    echo "Adresse mail de l'administrateur (default : admin@admin.com):"
    read -e wpMail
        if [ -z "$wpMail" ]
    then
        wpMail="admin@admin.com"
    fi
    wp config create --dbname=${dbName} --dbuser=${dbUser} --dbpass=${dbPwd}
    wp core install --url=${wpUrl} --title=${wpTitle} --admin_user=${wpUser} --admin_password=${wpPwd} --admin_email=${wpMail} --skip-email
    sudo service apache2 restart
    echo "Votre site $wpTitle a bien été installé."
}

# Main menu
function menu {
    options=("Installation" "Thèmes" "Plugins" "Reset" "Quitter")
    optionsThemes=("Ajouter" "Supprimer" "Activer" "Désactiver" "Rechercher" "Quitter")
    optionsPlugins=("Ajouter" "Supprimer" "Activer" "Désactiver" "Rechercher" "Quitter")
    choiceTheme=""
    choicePlugin=""
    echo -e "Sélectionnez une action"
    select responseAction in "${options[@]}";do
        case ${responseAction} in
            Installation ) choiceAction="Installation";break;;
            Thèmes ) choiceAction="Thèmes";break;;
            Plugins ) choiceAction="Plugins";break;;
            Reset ) choiceAction="Reset";break;;
            Quitter ) choiceAction="Quitter";break;;
        esac
    done

    # Quit action
    if [ "$choiceAction" == "Quitter" ]
    then
        echo "A bientôt"
        exit;
    fi

    # Reset action
    if [ "$choiceAction" == "Reset" ]
    then
        reset
        menu
    fi

    # Install action
    if [ "$choiceAction" == "Installation" ]
    then
        setup
        menu
    fi

    # Themes action
    if [ "$choiceAction" == "Thèmes" ]
    then
        select responseTheme in "${optionsThemes[@]}";do
            case ${responseTheme} in
                Ajouter ) choiceTheme="Ajouter";break;;
                Supprimer ) choiceTheme="Supprimer";break;;
                Activer ) choiceTheme="Activer";break;;
                Désactiver ) choiceTheme="Désactiver";break;;
                Rechercher ) choiceTheme="Rechercher";break;;
                Quitter ) choiceTheme="Quitter";break;;
            esac
        done

        # Qui action
        if [ "$choiceTheme" == "Quitter" ]
        then
            echo "A bientôt"
            exit;
        fi

        # Add theme action
        if [ "$choiceTheme" == "Ajouter" ]
        then
            echo "Le nom du thème à ajouter :"
            echo "PS: L'écrire sans majuscule et sans espace, se référer au slug avec l'option de recherche"
            read -e themeName
            addTheme ${themeName}
            menu
        fi

        # Delete theme action
        if [ "$choiceTheme" == "Supprimer" ]
        then
            echo "Le nom du thème à supprimer :"
            echo "PS: L'écrire sans majuscule et sans espace, se référer au slug avec l'option de recherche"
            read -e themeName
            deleteTheme ${themeName}
            menu
        fi

        # Enable theme action
        if [ "$choiceTheme" == "Activer" ]
        then
            echo "Le nom du thème à activer :"
            echo "PS: L'écrire sans majuscule et sans espace, se référer au slug avec l'option de recherche"
            read -e themeName
            enableTheme ${themeName}
            menu
        fi

        # Disable theme action
        if [ "$choiceTheme" == "Désactiver" ]
        then
            echo "Le nom du thème à désactiver :"
            echo "PS: L'écrire sans majuscule et sans espace, se référer au slug avec l'option de recherche"
            read -e themeName
            disableTheme ${themeName}
            menu
        fi

        # Search theme action
        if [ "$choiceTheme" == "Rechercher" ]
        then
            echo "Le nom du thème à rechercher :"
            echo "PS: L'écrire sans majuscule et sans espace, se référer au slug avec l'option de recherche"
            read -e themeName
            searchTheme ${themeName}
            menu
        fi
    fi

    #Plugins action
    if [ "$choiceAction" == "Plugins" ]
    then
        select responsePlugins in "${optionsPlugins[@]}";do
            case ${responsePlugins} in
                Ajouter ) choicePlugin="Ajouter";break;;
                Supprimer ) choicePlugin="Supprimer";break;;
                Activer ) choicePlugin="Activer";break;;
                Désactiver ) choicePlugin="Désactiver";break;;
                Rechercher ) choicePlugin="Rechercher";break;;
                Quitter ) choicePlugin="Quitter";break;;
            esac
        done

        # Qui action
        if [ "$choicePlugin" == "Quitter" ]
        then
            echo "A bientôt"
            exit;
        fi

        # Add plugin action
        if [ "$choicePlugin" == "Ajouter" ]
        then
            echo "Le nom du plugin à ajouter :"
            echo "PS: L'écrire sans majuscule et sans espace, se référer au slug avec l'option de recherche"
            read -e pluginName
            addPlugin ${pluginName}
            menu
        fi

        # Delete plugin action
        if [ "$choicePlugin" == "Supprimer" ]
        then
            echo "Le nom du plugin à supprimer :"
            echo "PS: L'écrire sans majuscule et sans espace, se référer au slug avec l'option de recherche"
            read -e pluginName
            deletePlugin ${pluginName}
            menu
        fi

        # Enable plugin action
        if [ "$choicePlugin" == "Activer" ]
        then
            echo "Le nom du plugin à activer :"
            echo "PS: L'écrire sans majuscule et sans espace, se référer au slug avec l'option de recherche"
            read -e pluginName
            enablePlugin ${pluginName}
            menu
        fi

        # Disable plugin action
        if [ "$choicePlugin" == "Désactiver" ]
        then
            echo "Le nom du plugin à désactiver :"
            echo "PS: L'écrire sans majuscule et sans espace, se référer au slug avec l'option de recherche"
            read -e pluginName
            disablePlugin ${pluginName}
            menu
        fi

        # Search plugin action
        if [ "$choicePlugin" == "Rechercher" ]
        then
            echo "Le nom du plugin à rechercher :"
            read -e pluginName
            searchPlugin ${pluginName}
            menu
        fi
    fi
}
menu
