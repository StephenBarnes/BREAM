data:extend({
    {
        type = "string-setting",
        name = "BREAM-surfaces-to-spawn-on",
        setting_type = "startup",
        default_value = "nauvis",
        order = "a",
    },
    {
        type = "string-setting",
        name = "BREAM-safe-tiles",
        setting_type = "startup",
        default_value = "stone-path,concrete,refined-concrete,tarmac,hazard-concrete-left,hazard-concrete-right,refined-hazard-concrete-left,refined-hazard-concrete-right",
        order = "b",
    },
    {
        type = "double-setting",
        name = "BREAM-spawn-every-seconds",
        setting_type = "startup",
        default_value = 0.5,
        order = "c",
    },
    {
        type = "double-setting",
        name = "BREAM-enemy-spawner-health-multiplier",
        setting_type = "startup",
        default_value = 1.0,
        minimum_value = 0.0,
        order = "d",
    },
    {
        type = "double-setting",
        name = "BREAM-enemy-spawner-healing-multiplier",
        setting_type = "startup",
        default_value = 1.0,
        minimum_value = 0.0,
        order = "e",
    },
    {
        type = "bool-setting",
        name = "BREAM-make-lamps-military-targets",
        setting_type = "startup",
        default_value = true,
        order = "f",
    },
    {
        type = "bool-setting",
        name = "BREAM-make-electric-poles-military-targets",
        setting_type = "startup",
        default_value = false,
        order = "g",
    },

------------------------------------------------------------------------

    {
        type = "double-setting",
        name = "BREAM-spawn-at-all-chance",
        setting_type = "runtime-global",
        default_value = 1.0,
        minimum_value = 0.0,
        maximum_value = 1.0,
        order = "a",
    },
    {
        type = "int-setting",
        name = "BREAM-num-chunks-to-check",
        setting_type = "runtime-global",
        default_value = 5,
        minimum_value = 0,
        order = "b",
    },
    {
        type = "double-setting",
        name = "BREAM-starting-peace-minutes",
        setting_type = "runtime-global",
        default_value = 5,
        minimum_value = 0,
        order = "c",
    },
    {
        type = "bool-setting",
        name = "BREAM-only-spawn-when-dark",
        setting_type = "runtime-global",
        default_value = true,
        order = "d",
    },
    {
        type = "int-setting",
        name = "BREAM-player-spawn-block-radius",
        setting_type = "runtime-global",
        default_value = 100,
        minimum_value = 0,
        order = "e",
    },
    {
        type = "int-setting",
        name = "BREAM-water-tile-spawn-block-radius",
        setting_type = "runtime-global",
        default_value = 5,
        minimum_value = 0,
        order = "f",
    },
    {
        type = "int-setting",
        name = "BREAM-safe-tile-spawn-block-radius",
        setting_type = "runtime-global",
        default_value = 0,
        minimum_value = 0,
        order = "g",
    },
    {
        type = "int-setting",
        name = "BREAM-entity-spawn-block-radius",
        setting_type = "runtime-global",
        default_value = 15,
        minimum_value = 0,
        order = "h",
    },
    {
        type = "double-setting",
        name = "BREAM-lamp-safety-factor",
        setting_type = "runtime-global",
        default_value = 1.2,
        minimum_value = 0,
        order = "j",
    },
    {
        type = "int-setting",
        name = "BREAM-enemy-spawn-block-radius",
        setting_type = "runtime-global",
        default_value = 100,
        minimum_value = 0,
        order = "k",
    },
    {
        type = "int-setting",
        name = "BREAM-enemy-count-for-spawn-blocking",
        setting_type = "runtime-global",
        default_value = 10,
        minimum_value = 0,
        order = "l",
    },
    {
        type = "double-setting",
        name = "BREAM-extra-bug-class-chance",
        setting_type = "runtime-global",
        default_value = 0.5,
        minimum_value = 0,
        maximum_value = 1,
        order = "m",
    },
    {
        type = "int-setting",
        name = "BREAM-max-bugs-per-swarm",
        setting_type = "runtime-global",
        default_value = 50,
        minimum_value = 1,
        order = "n",
    },
    {
        type = "double-setting",
        name = "BREAM-pollution-cost-multiplier",
        setting_type = "runtime-global",
        default_value = 0.2,
        minimum_value = 0,
        order = "o",
    },
    {
        type = "double-setting",
        name = "BREAM-min-pollution-for-spawn",
        setting_type = "runtime-global",
        default_value = 20,
        minimum_value = 0,
        order = "p",
    },
    {
        type = "double-setting",
        name = "BREAM-spawn-chance-at-min-pollution",
        setting_type = "runtime-global",
        default_value = 0.2,
        minimum_value = 0,
        maximum_value = 1,
        order = "q",
    },
    {
        type = "double-setting",
        name = "BREAM-pollution-for-max-spawn-chance",
        setting_type = "runtime-global",
        default_value = 100,
        minimum_value = 0,
        order = "r",
    },
    {
        type = "double-setting",
        name = "BREAM-spawn-chance-at-max-pollution",
        setting_type = "runtime-global",
        default_value = 1.0,
        minimum_value = 0,
        maximum_value = 1,
        order = "s",
    },
    {
        type = "double-setting",
        name = "BREAM-pollution-fraction-per-swarm-min",
        setting_type = "runtime-global",
        default_value = 0.3,
        minimum_value = 0,
        maximum_value = 1,
        order = "t",
    },
    {
        type = "double-setting",
        name = "BREAM-pollution-fraction-per-swarm-max",
        setting_type = "runtime-global",
        default_value = 0.9,
        minimum_value = 0,
        maximum_value = 1,
        order = "u",
    },

    {
        type = "bool-setting",
        name = "BREAM-debug-printing",
        setting_type = "runtime-global",
        default_value = false,
        order = "zz1",
    },
    {
        type = "bool-setting",
        name = "BREAM-player-pos-debug",
        setting_type = "runtime-global",
        default_value = false,
        order = "zz2",
    },
})