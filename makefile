Target = Hazard-Lights_18.0.1
FactorioModFolder = /home/spacecatchan/Documents/factorio/mods

all: $(Target)
	rm -rf $(FactorioModFolder)/$(Target)
	cp -r $(Target) $(FactorioModFolder)/$(Target)
