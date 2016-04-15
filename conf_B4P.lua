-- fichier : conf_B4P.lua
-- auteur  : Philuser

-- Attention : utiliser seulement des caracteres ASCII standard
-- les accents, cedilles et autres sont a proscrire 

-- Fichier de config des variables globales pour une meilleur portabilite 
-- en test pour les broches de ESP 
-- Adapter les parametres WIFI et MQTT 


-- une ligne en plus
-- Determination du brochage du ModeMCU
-- l'affectation des broches / GPIO reste a verifier
-- Controle effectue, Mapping LUA <-> GPIO OK
LED_RUN = 0 -- GPIO 16 - LED de Fontionnement
TMP_D20 = 1 -- GPIO 05 - Sonde de temperature D18B20
REL_PR1 = 2 -- GPIO 04 - Prise Relais 1 
RST_B4P = 3 -- GPIO 00 - Commutateur position mode Flash
REL_PR3 = 4 -- GPIO 02 - Prise Relais 3
REL_PR2 = 5 -- GPIO 14 - Prise Relais 2
SPARE00 = 6 -- GPIO 12 - Reserve
LED_WS2 = 7 -- GPIO 13 - LED WS2811
REL_PR4 = 8 -- GPIO 15 - Prise Relais 4

TAB_PRISE = {}
TAB_PRISE["REL_PR1"] = 2
TAB_PRISE["REL_PR2"] = 5
TAB_PRISE["REL_PR3"] = 4
TAB_PRISE["REL_PR4"] = 8
TAB_ACTION = {gpio.LOW,gpio.HIGH}

PORT = 8088 -- Port du serveur web 

-- config des timer
TIM_LED = 1
TIM_SON = 2 

--Paremetres WiFi
-- adapter ces parametres a votre installation
WIFI_SSID = "mon_SSID"
WIFI_PASS = "le_mot_de_passe"

-- Parametres MQTT
-- A adapter en fonction de votre serveur de messagerie MQTT
MQTT_CLIENTID = "bloc4prise"    -- identifiant de l'objet
MQTT_HOST = "62.210.210.210"     -- l'adresse du serveur
MQTT_PORT = 1883                -- Le port de communication

-- Message de Confirmation 
print("\nLes Variables globales sont chargees...\n")

