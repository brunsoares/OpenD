import Cycles "mo:base/ExperimentalCycles";
import Principal "mo:base/Principal";
import NFTActorClass "../NFT/nft";
import HashMap "mo:base/HashMap";
import List "mo:base/List";
import Iter "mo:base/Iter";

actor OpenD {
    
    private type Listing = {
        itemOwner: Principal;
        itemPrice: Nat;
    };
    
    var mapOfNFT = HashMap.HashMap<Principal, NFTActorClass.NFT>(1, Principal.equal, Principal.hash); 
    var mapOfOwners = HashMap.HashMap<Principal, List.List<Principal>>(1, Principal.equal, Principal.hash); 
    var mapOfListings = HashMap.HashMap<Principal, Listing>(1, Principal.equal, Principal.hash);

    public shared(msg) func mint(image: [Nat8], name: Text): async Principal{
        let owner: Principal = msg.caller;
        Cycles.add(100_500_000_000);
        let newNFT = await NFTActorClass.NFT(name, owner, image);
        let newNFTPrincipal = await newNFT.getCanisterID();

        mapOfNFT.put(newNFTPrincipal, newNFT);
        addOwnersFromMap(owner, newNFTPrincipal);

        return newNFTPrincipal;
    };

    private func addOwnersFromMap(owner: Principal, NFTID: Principal){
        var ownedNFT: List.List<Principal> = switch(mapOfOwners.get(owner)) {
            case null List.nil<Principal>();
            case (?result) result;
        };

        ownedNFT := List.push(NFTID, ownedNFT);
        mapOfOwners.put(owner, ownedNFT);
    };

    public query func getOwnedNFTs(user: Principal): async [Principal]{
        var ownedNFT: List.List<Principal> = switch(mapOfOwners.get(user)) {
            case null List.nil<Principal>();
            case (?result) result;
        };

        return List.toArray(ownedNFT);
    };

    public query func getListedNFT(): async [Principal]{
        let ids = Iter.toArray(mapOfListings.keys());
        return ids;
    };

    public shared(msg) func listItem(id: Principal, price: Nat): async Text{
        var item: NFTActorClass.NFT = switch(mapOfNFT.get(id)) {
            case null return "NFT does not exist!";
            case (?result) result;
        };

        let owner = await item.getOwner();
        if(Principal.equal(owner, msg.caller)){
            let newListing: Listing = {
                itemOwner = owner;
                itemPrice = price;
            };
            mapOfListings.put(id, newListing);
            return "Success!";
        } else {
            return "You don't own the NFT!";
        };

    };

    public query func getOpendCanisterID(): async Principal{
        return Principal.fromActor(OpenD);
    };

    public query func isListed(id: Principal): async Bool{
        if(mapOfListings.get(id) == null){
            return false;
        } else {
            return true;
        }
    };

    public query func getOriginalOwner(id: Principal): async Principal{
        var listing: Listing = switch(mapOfListings.get(id)){
            case null return Principal.fromText("");
            case (?result) result;
        };
        
        return listing.itemOwner;
    };
    
    public query func getSellPrice(id: Principal): async Nat{
        var listing: Listing = switch(mapOfListings.get(id)){
            case null return 0;
            case (?result) result;
        };
        
        return listing.itemPrice;
    };

    public shared(msg) func completePurchase(id: Principal, ownerId: Principal, newOwnerId: Principal): async Text{
        var purchasedNFT: NFTActorClass.NFT = switch(mapOfNFT.get(id)){
            case null return "NFT does not exist!";
            case (?result) result;
        };
        
        let transferResult = await purchasedNFT.transferOwnership(newOwnerId);
        if(transferResult == "Success!"){
            mapOfListings.delete(id);
            var ownedNFT: List.List<Principal> = switch(mapOfOwners.get(ownerId)){
                case null List.nil<Principal>();
                case (?result) result;
            };

            ownedNFT := List.filter(ownedNFT, func(listItemId: Principal): Bool{
                return listItemId != id;
            });

            addOwnersFromMap(newOwnerId, id);
            return "Success!";
        
        } else {
            return transferResult;
        }

    };

};
