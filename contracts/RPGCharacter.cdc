import NonFungibleToken from "./utility/NonFungibleToken.cdc"

pub contract RPGCharacter : NonFungibleToken {

    pub var totalSupply: UInt64

    pub let CollectionStoragePath: StoragePath
    pub let CollectionPublicPath: PublicPath
    pub let CollectionPrivatePath: PrivatePath

    pub event ContractInitialized()
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id: UInt64, to: Address?)
    
    
    pub resource NFT : NonFungibleToken.INFT {
        pub let id: UInt64
        pub let name: String
        access(contract) var experience: UInt16
        access(contract) var level: UInt8
        access(contract) var health: UInt8

        init(name: String) {
            self.id = self.uuid
            self.name = name
            self.experience = 0
            self.level = 1
            self.health = 100
        }

        access(contract) fun addExperience(amount: UInt16) {
            self.experience = self.experience + amount
        }

        access(contract) fun updateLevel(newLevel: UInt8) {
            self.level = newLevel
        }
    }

    pub resource interface CollectionPublic {
        pub fun getIDs(): [UInt64]
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
        pub fun borrowNFTSafe(id: UInt64): &NonFungibleToken.NFT? {
            post {
                result == nil || result!.id == id: "The returned reference's ID does not match the requested ID"
            }
        }
        pub fun borrowRPGCharacterNFT(id: UInt64): &NFT? {
            post {
                (result == nil) || (result?.id == id):
                    "Cannot borrow NFT reference: the ID of the returned reference is incorrect"
            }
            return nil
        }
    }

    pub resource Collection : NonFungibleToken.Receiver, NonFungibleToken.Provider, NonFungibleToken.CollectionPublic, CollectionPublic {
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

        init() {
            self.ownedNFTs <-{}
        }

        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            pre {
                self.ownedNFTs.containsKey(id): "No NFT with given id in Collection!"
            }
            return (&self.ownedNFTs[id] as! &NonFungibleToken.NFT?)!
        }

        pub fun borrowNFTSafe(id: UInt64): &NonFungibleToken.NFT? {
            return &self.ownedNFTs[id] as! &NonFungibleToken.NFT?
        }

        pub fun borrowRPGCharacterNFT(id: UInt64): &NFT? {
            if self.ownedNFTs[id] != nil {
                // Create an authorized reference to allow downcasting
                let ref = (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)!
                return ref as! &NFT
            }
            return nil
        }

        pub fun deposit(token: @NonFungibleToken.NFT) {
            let token <- token as! @NFT

            let id: UInt64 = token.id

            // add the new token to the dictionary which removes the old one
            let oldToken <- self.ownedNFTs[id] <- token

            emit Deposit(id: id, to: self.owner?.address)

            destroy oldToken
        }

        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("missing NFT")

            emit Withdraw(id: token.id, from: self.owner?.address)

            return <-token
        }

        destroy() {
            destroy self.ownedNFTs
        }
    }

    pub fun createEmptyCollection(): @NonFungibleToken.Collection {
        return <-create Collection()
    }

    pub resource Admin {
        pub fun mintNFT(name: String): @NonFungibleToken.NFT {
            RPGCharacter.totalSupply = RPGCharacter.totalSupply + 1
            return <-create NFT(name: name)
        }

        pub fun addExperience(amount: UInt16, nftRef: &NFT) {
            nftRef.addExperience(amount: amount)
        }

        pub fun updateLevel(newLevel: UInt8, nftRef: &NFT) {
            nftRef.updateLevel(newLevel: newLevel)
        }
    }

    init() {

        self.totalSupply = 0

        self.CollectionStoragePath = /storage/RPGCharacterCollection
        self.CollectionPublicPath = /public/RPGCharacterCollectionPublic
        self.CollectionPrivatePath = /private/RPGCharacterCollectionPublic

        let collection <-create Collection()
        collection.deposit(token: <-create NFT(name: "Dragonborn"))
        self.account.save(<-collection, to: self.CollectionStoragePath)
        self.account.link<&Collection{NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, CollectionPublic}>(self.CollectionPublicPath, target: self.CollectionStoragePath)
        self.account.link<&Collection{NonFungibleToken.Receiver, NonFungibleToken.Provider, NonFungibleToken.CollectionPublic, CollectionPublic}>(self.CollectionPrivatePath, target: self.CollectionStoragePath)
        
        emit ContractInitialized()
    }
}