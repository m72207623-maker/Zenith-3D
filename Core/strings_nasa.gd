class_name StringsNasa
extends RefCounted
## "NASA Resources" screen texts. The links themselves live in Menus/TempMenu/nasa_resources.gd.

const DATA: Dictionary = {
	"SET_MUSIC_VOL": ["Music volume", "Гучність музики"],
	"SET_SFX_VOL": ["SFX volume", "Гучність ефектів"],
	"SET_MUSIC_ON": ["Music", "Музика"],
	"CREDITS_TITLE": ["Credits", "Автори"],
	"CREDITS_MUSIC": ["Music composed and produced by Danylo Seredniak.", "Музику створив і спродюсував Данило Середняк."],
	"MENU_NASA": ["NASA Resources", "Ресурси NASA"],
	"NR_TITLE": ["NASA Resources", "Ресурси NASA"],
	"NR_INTRO": ["Real NASA material that inspired ZENITH. The gameplay is simplified on purpose: it teaches the trade-offs of mission design, it is not an engineering tool.", "Справжні матеріали NASA, що надихнули ZENITH. Геймплей навмисно спрощений: гра вчить компромісів проєктування місій, а не замінює інженерні розрахунки."],
	"NR_OPEN": ["Open link", "Відкрити"],
	"NR_COPY": ["Copy link", "Копіювати"],
	"NR_COPIED": ["Link copied", "Скопійовано"],
	"NR_LOOP": ["NASA-style loop: scientific objective -> design -> verification -> launch -> results", "Цикл у стилі NASA: наукова мета -> проєкт -> верифікація -> запуск -> результати"],
	"NR_SE": ["The design loop of every mission: science goal -> requirements -> design -> verification (Mission Validation) -> launch -> operations -> results.", "Цикл проєкту кожної місії: наукова мета -> вимоги -> проєкт -> верифікація (Валідація місії) -> запуск -> експлуатація -> результати."],
	"NR_ROCKET": ["Thrust, specific impulse and the rocket equation behind the rocket designer (delta-v, thrust-to-weight, staging).", "Тяга, питомий імпульс і рівняння ракети в основі конструктора (дельта-v, тяга до ваги, ступені)."],
	"NR_ORBIT": ["Orbit basics used in the flight HUD: apoapsis, periapsis and the sideways speed needed to stay in orbit.", "Основи орбіт у польотному HUD: апоцентр, перицентр і бічна швидкість, потрібна для утримання на орбіті."],
	"NR_EARTH": ["Science goals of Mission 1: Earth observation, climate, land and ocean monitoring.", "Наукові цілі Місії 1: спостереження Землі, клімат, моніторинг суші й океанів."],
	"NR_EO": ["Examples of what multispectral imaging reveals, behind the instrument choices and science return.", "Приклади того, що показує мультиспектральна зйомка: вибір приладів і наукова віддача."],
	"NR_WORLDVIEW": ["Real satellite imagery, the kind of data the player's Earth-observation satellite would deliver.", "Справжні супутникові знімки - дані, які доставив би ваш супутник спостереження Землі."],
	"NR_HELIO": ["Space-weather science goal: the Sun, solar wind and their effect on satellites and Earth.", "Наукова мета «космічна погода»: Сонце, сонячний вітер і їхній вплив на супутники та Землю."],
	"NR_ISS": ["Context for Missions 2 and 3: spacewalk repair (EVA) and rendezvous and docking with the station.", "Контекст Місій 2 і 3: ремонт під час виходу у відкритий космос та зближення й стикування зі станцією."],
	"NR_SMALLSAT": ["Small satellites and constellations for Mission 4: many spacecraft deployed from one launch.", "Малі супутники й групування для Місії 4: багато апаратів з одного запуску."],
	"NR_ARTEMIS": ["Mission 5: heavy launch system, trans-lunar injection, lunar landing and return to Earth.", "Місія 5: важка ракета, переліт до Місяця, посадка та повернення на Землю."],
	"NR_MOON": ["Lunar facts and science used for the landing site, rover sampling and the shortened surface day.", "Дані про Місяць для місця посадки, відбору зразків ровером і скороченої доби на поверхні."],
	"NR_APOLLO": ["Historic reference for the landing, surface science and return profile of Mission 5.", "Історичний орієнтир для посадки, роботи на поверхні й повернення в Місії 5."],
}
