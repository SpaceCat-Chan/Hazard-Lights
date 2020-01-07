Target = Hazard-Lights_17.0.5
FactorioModFolder = /home/spacecatchan/Documents/factorio/mods

all: $(Target)
	rm -rf $(FactorioModFolder)/$(Target)
	cp -r $(Target) $(FactorioModFolder)/$(Target)
