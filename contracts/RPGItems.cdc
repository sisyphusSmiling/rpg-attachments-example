import IRPGItems from "./IRPGItems.cdc"

pub contract RPGItems {

    pub resource OrcishArrows : IRPGItems.Arrows {
        pub let name: String
        pub let damage: UInt8
        pub var numberOfArrows: UInt8

        init() {
            self.name = "Orcish Arrows"
            self.damage = 8
            self.numberOfArrows = 10
        }

        access(contract) fun addArrows(_ arrows: UInt8) {
            self.numberOfArrows = self.numberOfArrows + arrows
        }

        access(contract) fun removeArrows(_ arrows: UInt8) {
            if self.numberOfArrows < arrows {
                self.numberOfArrows = 0
            } else {
                self.numberOfArrows = self.numberOfArrows - arrows
            }
        }
    }

    pub resource ElvenArrows : IRPGItems.Arrows {
        pub let name: String
        pub let damage: UInt8
        pub var numberOfArrows: UInt8

        init() {
            self.name = "Elven Arrows"
            self.damage = 10
            self.numberOfArrows = 10
        }
    }

    pub resource GuildMastersArmor : IRPGItems.Armor {
        pub let name: String
        pub let defense: UInt8

        init() {
            self.name = "Guild Master's Armor"
            self.defense = 8
        }
    }

    pub resource DragonscaleArmor : IRPGItems.Armor {
        pub let name: String
        pub let defense: UInt8

        init() {
            self.name = "Dragonscale Armor"
            self.defense = 8
        }
    }

    pub resource Admin {
        pub fun createOrcishArrows(): @OrcishArrows {
            return <-create OrcishArrows()
        }
        pub fun createElvenArrows(): @ElvenArrows {
            return <-create ElvenArrows()
        }
        pub fun createGuildMastersArmor(): @GuildMastersArmor {
            return <-create GuildMastersArmor()
        }
        pub fun createDragonscaleArmor(): @DragonscaleArmor {
            return <-create DragonscaleArmor()
        }
    }

}