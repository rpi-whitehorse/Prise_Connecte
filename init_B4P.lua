-- fichier : init_B4P.lua
-- Auteur	: philuser

-- Programme de lancement de l'application 'prise connectee'
tmr.delay(1000000)
node.compile("UL18B20.lua")

-- Chargement des variables globales 
dofile("conf_B4P.lua")

--Init des GPIO Pour les 4 relais/prises  
-- la sonde D20BS18 et la LED Signal tricolor
function init_GPIO(freq, duty)

	-- Init Led marche
	gpio.mode(LED_RUN,gpio.OUTPUT) -- La LED de fonctionnement
	gpio.write(LED_RUN,gpio.LOW)

	-- Relais 1
	gpio.mode(REL_PR1,gpio.OUTPUT)
	gpio.write(REL_PR1,gpio.LOW) -- Init Relais 1

	-- Relais 2
	gpio.mode(REL_PR2,gpio.OUTPUT)
	gpio.write(REL_PR2,gpio.LOW) -- Init Relais 2

	-- Relais 3
	gpio.mode(REL_PR3,gpio.OUTPUT)
	gpio.write(REL_PR3,gpio.LOW) -- Init Relais 3

	-- Relais 4
	gpio.mode(REL_PR4,gpio.OUTPUT)
	gpio.write(REL_PR4,gpio.LOW) -- Init Relais 4

	-- LED Mode WS2811
	gpio.mode(LED_WS2,gpio.OUTPUT)
	gpio.write(LED_WS2,gpio.LOW) -- Init LED RGB WS2811

	-- sonde de temperature
	gpio.mode(TMP_D20,gpio.INPUT) -- Sonde Dallas D20B18


end 


-- Initialisatin des GPIO 
print("Initialisation des GPIO\n")
init_GPIO()

-- Fixe le Wifi en mode STATION pour se connecter au reseau
wifi.setmode(wifi.STATION)


-- quelques Print's pour connaitre l'etat du mode wifi courant (info de Debug)
print('\n\nWifi en Mode STATION :',	'mode='..wifi.getmode())
print('MAC Adresse : ',		wifi.sta.getmac())
print('Identification le la puce ID : ',			node.chipid())
print('Taille memoire : ',		node.heap(),'\n')


-- Connection au resau
wifi.sta.config(WIFI_SSID, WIFI_PASS)


-- Initialisation du compteur de connexion au reseau
local rot_color = 0
local color ={0,0,0}

print("Tentative de Connexion au reseau Wifi : ",WIFI_SSID)
-- execution d'une fonction d'alarme 1s, boucle de connexion reseau 
-- Le chenilard sur la LED indique la tentative de connection
-- en cas de succes la LED RVB vire au blanc
tmr.alarm(0, 100, 1, function()
	
	if wifi.sta.getip() == nil then		
		-- gestion du chenillar de couleur indiquant la tentative de connexion reseau
		color[rot_color %4]=0
		rot_color = rot_color + 1     
		color[rot_color %4]=255

		ws2812.writergb(LED_WS2, string.char(color[1],color[2],color[3]))
		
   	else
    	ip, nm, gw = wifi.sta.getip()
      	
    	-- Information de debug
      	print("\n\nInformation de connexion au reseau: \nAdresse IP: ",ip)
      	print("Masque de reseau: ",nm)
      	print("Adresse de la passerelle : ",gw,'\n')
      	
      	tmr.stop(0)		-- Fin de la boucle de connexion
      	ws2812.writergb(LED_WS2, string.char(128,128,128))
      	
      	
      	print("\n\nfin du process de connexion")
      	
      	-- On passe la main au programme principal des que la connexion est etablie
      	--dofile("mqtt_B4P.lua")
        --dofile("ds18b20_thinspeak.lua")
        dofile("prog_B4P.lua")
   	end
end)
