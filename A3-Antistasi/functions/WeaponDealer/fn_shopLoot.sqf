//Pistols first
["allHandguns", "Handguns"] call A3A_fnc_sortWeaponArray;

//All rifles
["allRifles", "Rifles"] call A3A_fnc_sortWeaponArray;
["allSniperRifles", "SniperRifles"] call A3A_fnc_sortWeaponArray;
["allMachineGuns", "MachineGuns"] call A3A_fnc_sortWeaponArray;
["allSMGs", "SMGs"] call A3A_fnc_sortWeaponArray;
["allShotguns", "Shotguns"] call A3A_fnc_sortWeaponArray;
//Mash all arrays into one big one
allRiflesShop = allRifles + allSniperRifles + allMachineGuns + allSMGs + allShotguns;

["allMissileLaunchers", "MissileLaunchers"] call A3A_fnc_sortWeaponArray;
["allRocketLaunchers", "RocketLaunchers"] call A3A_fnc_sortWeaponArray;
//Mash all arrays into one big one
allLaunchersShop = allMissileLaunchers + allRocketLaunchers;

//Sort explosives by damage, explosion radius and maybe weight
allExplosiveShop = +lootExplosive;

//Ammo is getting randomised (or shouldnt it? Look out for balancing issues)
allAmmunitionShop = +lootMagazine;

//Sort by armor level, weight, load, and resistance
allVestsShop = +lootVest;

//Sort by weight and load
allBackpacksShop = +lootBackpack;

//Sorted by the order here
allItemsShop = lootBasicItem + allBinoculars + allRadios + allGPS + allMineDetectors + allLaserBatteries + allLaserDesignators + allUAVTerminals  + allGadgets;

//Sort by protection and weight
allHelmetsShop = +lootHelmet;

//The complete array
shopArrayComplete = [[allHandguns, 0, false], [allRiflesShop, 1, false], [allLaunchersShop, 2, false], [allExplosiveShop, 3, false], [allAmmunitionShop, 4, true], [lootAttachment, 5, true], [allVestsShop, 6, false], [allBackpacksShop, 7, false], [lootNVG, 8, true], [allItemsShop, 9, false], [lootGrenade, 10, true], [allHelmetsShop, 11, false]];
