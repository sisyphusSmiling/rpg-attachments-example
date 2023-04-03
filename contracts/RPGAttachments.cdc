import RPGCharacter from "./RPGCharacter.cdc"
import IRPGItems from "./IRPGItems.cdc"


pub contract RPGAttachments {
    
    pub attachment Quiver for RPGCharacter.NFT {
        pub var arrows: @{IRPGItems.Arrows}?
        
        init() {
            self.arrows <-nil
        }

        pub fun borrowArrows(): &{IRPGItems.Arrows}? {
            return &self.arrows as &{IRPGItems.Arrows}?
        }

        access(contract) fun updateArrows(_ new: @{IRPGItems.Arrows}): @{IRPGItems.Arrows}? {
            if self.arrows == nil {
                self.arrows <-! new
                return nil
            } else {
                let old <- self.arrows <- new
                return <-old
            }
        }

        destroy() {
            destroy self.arrows
        }
    }

    pub attachment Wardrobe for RPGCharacter.NFT {
        pub var armor: @{IRPGItems.Armor}?
        
        init() {
            self.armor <-nil
        }

        pub fun borrowArrows(): &{IRPGItems.Armor}? {
            return &self.armor as &{IRPGItems.Armor}?
        }

        access(contract) fun updateArmor(_ new: @{IRPGItems.Armor}): @{IRPGItems.Armor}? {
            if self.armor == nil {
                self.armor <-! new
                return nil
            } else {
                let old <- self.armor <- new
                return <-old
            }
        }

        destroy() {
            destroy self.armor
        }
    }

    pub resource Admin {
        access(account) fun addAttachment(character: @RPGCharacter.NFT, attachmentType: Type): @RPGCharacter.NFT {
            switch attachmentType {
                case Type<&Quiver>():
                    if character[Quiver] == nil {
                        return <- attach Quiver() to <- character
                    }
                case Type<&Wardrobe>():
                    if character[Wardrobe] == nil {
                        return <- attach Wardrobe() to <- character
                    }
            }
            return <-character
        }
    }
}
 