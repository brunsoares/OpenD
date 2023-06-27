import Cycles "mo:base/ExperimentalCycles";
import Principal "mo:base/Principal";
import NFTActorClass "../NFT/nft";
import HashMap "mo:base/HashMap";
import List "mo:base/List";

actor OpenD {
    
    var mapOfNFT = HashMap.HashMap<Principal, NFTActorClass.NFT>(1, Principal.equal, Principal.hash); 
    var mapOfOwners = HashMap.HashMap<Principal, List.List<Principal>>(1, Principal.equal, Principal.hash); 

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
    }

};
