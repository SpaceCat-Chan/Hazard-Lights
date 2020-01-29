data:extend{
    {
        name = "HazardLights-ReScanBool",
        type = "bool-setting",
        setting_type = "runtime-global",
        order = "a",
        default_value = false
    },
    {
        name = "HazardLights-ReScanTimer",
        type = "int-setting",
        setting_type = "runtime-global",
        order = "b",
        default_value = 120,
        minimum_value = 10
    },
    {
        name = "HazardLights-Intensity",
        type = "double-setting",
        setting_type = "runtime-global",
        order = "c-a",
        default_value = 0.7,
        minimum_value = 0
    },
    {
        name = "HazardLights-Scale",
        type = "double-setting",
        setting_type = "runtime-global",
        order = "c-b",
        default_value = 0.3,
        minimum_value = 0
    },
    {
        name = "HazardLights-Red",
        type = "double-setting",
        setting_type = "runtime-global",
        order = "c-c",
        default_value = 0.9,
        minimum_value = 0
    },
    {
        name = "HazardLights-Alpha",
        type = "double-setting",
        setting_type = "runtime-global",
        order = "c-e",
        default_value = 0.6,
        minimum_value = 0
    }
}