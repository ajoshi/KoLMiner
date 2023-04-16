const String VOLC_OUTFIT_NAME_DESCRIPTION =
    "You need to have an outfit that lets you mine 70s gold. The app will automatically equip it to mine";
const String POST_MINING_OUTFIT_NAME_DESCRIPTION =
    "This is the name of the outfit the app will equip after mining is completed (or if it tries "
    "to mine and fails because it's out of adventures or other reasons) \nMaking this your rollover outfit is probably safest";
const String FOOD_DESCRIPTION =
    "This is the id of the food item you want the app to consume in autoconsume mode."
    "\n\nFind it by using the idFinder below";
const String BOOZE_DESCRIPTION =
    "This is the id of the booze item you want the app to consume in autoconsume mode"
    "\n\nFind it by using the idFinder below";

const String SKILL_GENERIC_DESC =
    "You'll probably generate a lot of MP while mining. This app can burn extra MP by summoning resolutions "
    "or whatever when your MP gets too high";
const String SKILL_DESCRIPTION = SKILL_GENERIC_DESC +
    "\n\nEnter the skill id here if you want the app to burn extra MP. Find it by using the idFinder below";
const String MAX_MP_DESCRIPTION = SKILL_GENERIC_DESC +
    "\n\nThe app won't cast this skill if MP is lower than this limit. I put this at 1000";

const String CHAT_CMD_DESC =
    "This app can run chat commands! Giving a command a name will create a button you can tap to run the command. "
    "\n\nCommands are stored without a slash. Try out exciting commands like \'chug bucket of win\', \'w buffy ode\', and \'logout\'";

const String MIN_HP_DESC =
    "The loving touch of a lonely nun can raise any spirits\n\n"
    "Optimal people can leave this empty, but being at 1 HP because you have an HP regen outfit still reduces your Max MP because "
    "you're always beaten up. I put it at 800";

const String AUTOSELL_GOLD_DESC =
    "Gold autosells for ... whatever it autosells for. You can disable autoselling (Enabled by default) "
    "if you want to collect gold for a collection or to sell to a bot or to grind into sausage. You do you.";

const String AUTOCONSUME_DESC =
    "Sometimes you're in a rush and just need to burn turns 5 minutes before RO. Typing out eat/drink/whatever "
    "by hand? Ain't nobody got time for that!"
    "\n\nEnter the list of chat commands (pretty much unbounded except for public chat) and they'll be executed when autoconsuming";

const String DEFAULT_AUTOCONSUME_MENU =
    "cast ode\nuse milk of mag\nchug elemental caip\nchug 6 perfect negroni\nuse distension pill\neat 7 veggie ricotta cass\nchug vulgar pitcher";

const String FSD_DESC =
    "Using the power of generative Web 3.0 AI coupled with Knob Fungal Tokens, this app can eat, drink, spleen and mine for you"
    "\n\nFill out the diet/booze/consumption plan you want in the Breakfast box below and Full Self Drilling will be engaged whenever you mine with no turns specified."
    "\n\nFailure to consume doesn't stop anything, so only enable this if you trust machines";
