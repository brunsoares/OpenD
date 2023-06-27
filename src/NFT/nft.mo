import Principal "mo:base/Principal";


actor class NFT(name: Text, owner: Principal, content: [Nat8]) = this {

    let itemName = name;
    let ownerName = owner;
    let imageContent = content;

    public query func getName() : async Text{
        return itemName
    };

    public query func getOwner() : async Principal{
        return ownerName;
    };

    public query func getImage() : async [Nat8]{
        return imageContent;
    };

    public query func getCanisterID(): async Principal{
        return Principal.fromActor(this);
    }

};