--------------------------------------------------------------------------------
-- Pilotage de la sonde dallas DS18B20 en LUA
-- programmation epurer pour gagner en place
-- date : 16/02/16
-- auteur : philuser
--------------------------------------------------------------------------------

-- Configuration du programme en mode MODULE
local modname = ...
local M = {}
_G[modname] = M
--------------------------------------------------------------------------------
-- declaration des variables local pour le module
--------------------------------------------------------------------------------
-- la table module
local tbl = table
-- la variable de nommage du module
local str = string
-- la config du mode Dallas One Wire ow
local ow1 = ow
-- declaration du timer
local tm1 = tmr
-- Limitation memoire (peut etre ajuster)
setfenv(1,M)
--------------------------------------------------------------------------------
-- Une implementation de la lecture de la sonde aussi courte que possible
--------------------------------------------------------------------------------

function readNumber(pin)
        -- affectation de l'adresse du module ow
        ow1.setup(pin)
        ow1.reset(pin)
        ow1.write(pin, 0xCC, 1)
        ow1.write(pin, 0xBE, 1)
        -- init mesure
        data = nil
        data = ""
        -- lecture sur 2 octets de la mesure de temp
        for i = 1, 2 do
            valeur = data .. str.char(ow1.read(pin))
        end
        -- Traitement et mise en grandeur de la valeur de mesure en temperature reel
        temp = (valeur:byte(1) + valeur:byte(2) * 256) / 16
        -- en cas d'overflow
        if (temp>4096) then
            temp=temp-4096
        end
        -- libere la mémoire du module ow
        ow1.reset(pin)
        ow1.write(pin,0xcc,1)
        ow1.write(pin, 0x44,1)  
        -- renvoi de la temperature de la sonde BS20
        return temp          
end

-- Return module table
return M
