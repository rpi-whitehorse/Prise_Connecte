-- fichier	: mqtt_B4P.lua
-- auteur	: philuser

tbl_fnt = {}

-- Initialisation d'un compteur local. sera utiliser dans le calcul modulo
local count = 0

function pilot_prise(m,pl)
	-- Lecture des messages mqtt de pilotage des prises de courant
	m:publish("/b4p/info/prise/", "--> pilotage du bloc 4 prises ", 0, 0,
			function(m) print("demande de changement de statut de la prise : ",pl) end)	
    -- message 'REL_PRx y' avec x=[1,4] correspondant au num prise et y=[0,1] pour ON,OFF 
	prise = string.sub(pl,1,7)
	action = tonumber(string.sub(pl,9,9))
	print("Prise : ",prise)
	print("Action : ",action)
    print("TAB_PRISE[prise] :",TAB_PRISE[prise])
    print("TAB_ACTION[action] :",TAB_ACTION[action])
    
	gpio.write(TAB_PRISE[prise],action)
end

function sonde( m,pl )
	-- activation de la lecture de la sonde
	m:publish("/b4p/info/sonde", "--> Activation lecture de la sonde ", 0, 0,
			function(m) print("demande d'activation de la sonde : ",pl) end)

	if pl == "lecture_temp" then
		-- Message demande d'extintion de la LED via MQTT 
		m:publish("/b4p/info/sonde", "--> Envoi de la sonde sur le site Thinspeack", 0, 0,
			function(m) print("Envoi de la sonde sur le site Thinspeack") end)

        -- sequence d'envoi de la valeur de la sonde sur le site de Thinspeack
		tmr.alarm(TIM_SON,60000,1,function()
			-- on charge le module de lecture de la sonde en memoire
            t = require("UL18B20")
		  	t1 = t.readNumber(TMP_D20)
		  	-- j'elimine la premire mesure a 85c
 		 	if t1 < 80 then
 		 		-- j'envoi la temp sur le canal MQTT + impression de debug local
  			    print("Temp:"..t1 .. "."..string.format("%02d", t1).." C\n")
  	            m:publish("/b4p/mesure/sonde", t1, 0, 0,
                   function(m) print("mesure de la sonde : "..t1) end)

  	            -- un petit bip-bip lumineux sur la led pour indiquer l'envoi de la temp
  	            -- on stop le timer d'animation precedent pour une nouvelle sequense
        		tmr.stop(TIM_LED)
        		local r = 0
        		local v = 0
        		local b = 255
				local tb_couleur={r,v,b}
				local nb_flash = 6
				local cpt = 0

				tmr.alarm(TIM_LED,500,1,function()
					if cpt %2 > 0 then
						r = 255
						v = 255
					else
						r = 0
						v = 0
					end
    				ws2812.writergb(LED_WS2, string.char(r,v,b))
    				cpt = cpt + 1
    				if cpt > nb_flash then
    					ws2812.writergb(LED_WS2, string.char(32,32,32))
        				tmr.stop(TIM_LED)
    				end
				end)
		    end
		    -- on libere le module de la memoire
            t = nil
            UL18B20 = nil
            package.loaded["UL18B20"] = nil
  			
		end)

	elseif pl == "stop_temp" then
		-- on stop le timer sonde pour une nouvelle sequense
        tmr.stop(TIM_SON)

	else
		-- Envoi d'un message d'erreur au broker MQTT
		-- Pour indiquer que quelque chose c'est mal passe
		m:publish("/b4p/info/sonde/", "--> Erreur sonde : Commande Inconnue pour l'instant", 0, 0,
			function(m) print("ERREUR SONDE : COMMANDE INCONNUE pour l'instant :") end)
	end
end


-- Assignation d'un nom au canal de diffussion (topic) 
-- tbl_fnt["/b4p/cmd/ledanim"] = ledanim
tbl_fnt["/b4p/cmd/pilot_prise"] = pilot_prise
tbl_fnt["/b4p/cmd/sonde"] = sonde

-- Instanciation du Client MQTT avec une valeur de maintient de 60s
print("creation de ojbet de connexion")
m = mqtt.Client(MQTT_CLIENTID, 120, "login", "PasseWord") -- dans ce mode de test on se passe d'utilisateur et de MdP

-- Declaration d'un message de fin de vie (lwt pour Last Will and Testament)
-- Le broker MQTT publira ce message quand : qos = 0, retain = 0, data = "offline"
-- sur le canal (topic) /lwt si le client MQTT n'aquite pas le signal de vie
m:lwt("/lwt", "Deconnexion brutal", 0, 0)


-- Lorsque le Client se connecte, impression d'un message d'etat 
-- et s'abonne au canal (Topic) "cmd"
m:on("connect", function(m) 
	-- Message de connexion au broker MQTT
	print ("\n\n", MQTT_CLIENTID, " Connexion au broker MQTT : ", MQTT_HOST,
		" au port ", MQTT_PORT, "\n\n")

	-- Abonnement au canal (Topic) auquel l'ESP8266 recoit commandes et ordres 
	m:subscribe("/b4p/cmd/#", 0,
		function(m) print("Abonnement au canal /b4p/cmd/#") end)
end)


-- Lors de la deconnection du client, imprimer le message de deconnection
-- et la memoire libre disponible 
m:on("offline", function(m)
	print ("\n\nDeconnexion du broker MQTT Mosquitto")
	print("Heap: ", node.heap())
end)


-- A la reception d'un message evenement, interpretation de la commande 
-- et distribution de l'action
m:on("message", function(m,t,pl)
	print("\n\nCONNEXION: ", m)
	print("CANAL: ", t)
	print("COMMANDE: ", pl)
	
	-- Cette fonction repend le principe de la commande Client de Paho-Python
	-- client.message_callback_add()
	-- Cela permet d'exectuter differentes fonction selon le message et le canal 
	if pl~=nil and tbl_fnt[t] then
		tbl_fnt[t](m,pl)
	end
end)

-- Connect to the broker
m:connect(MQTT_HOST, MQTT_PORT, 0, 1)
