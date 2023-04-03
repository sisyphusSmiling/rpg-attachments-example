pub contract IRPGItems {
    
    pub resource interface Arrows {
        pub let name: String
        pub let damage: UInt8
        pub var numberOfArrows: UInt8
        access(contract) fun addArrows(_ arrows: UInt8)
        access(contract) fun removeArrows(_ arrows: UInt8)
    }

    pub resource interface Armor {
        pub let name: String
        pub let defense: UInt8
    }
}