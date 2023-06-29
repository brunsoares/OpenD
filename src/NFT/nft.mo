import Principal "mo:base/Principal";


actor class NFT(name: Text, owner: Principal, content: [Nat8]) = this {

    private let itemName = name;
    private var ownerName = owner;
    private let imageContent = content;

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
    };

    public shared(msg) func transferOwnership(newOwner: Principal): async Text{
        if(msg.caller == ownerName){
            ownerName := newOwner;
            return "Success!";
        } else {
            return "Error: Not initiated by NFT Owner!";
        }
    }; 

};