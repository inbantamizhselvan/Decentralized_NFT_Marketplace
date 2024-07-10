import Cycles "mo:base/ExperimentalCycles";
import Debug "mo:base/Debug";
import NFTActorClass "../nft_backend/nft";
import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import List "mo:base/List";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";
import Bool "mo:base/Bool";


actor OpenD {
    private type Listing ={
      itemOwner : Principal;
      itemPrice :Nat;
    };
    var mapOfNFTs = HashMap.HashMap<Principal, NFTActorClass.NFT>(1, Principal.equal, Principal.hash);
    var mapOfOwners = HashMap.HashMap<Principal, List.List <Principal>>(1, Principal.equal, Principal.hash);
    var mapofListings = HashMap.HashMap<Principal, Listing>(1, Principal.equal, Principal.hash);


    public shared(msg) func mint(imgData: [Nat8], name: Text) : async Principal {
      let owner : Principal = msg.caller;

      Debug.print(debug_show(Cycles.balance()));
      Cycles.add<system>(500_500_000_000);
      let newNFT = await NFTActorClass.NFT(name, owner, imgData);
      Debug.print(debug_show(Cycles.balance()));

      let newNFTPrincipal = await newNFT.getCanisterId();
      mapOfNFTs.put(newNFTPrincipal, newNFT);
      addToMembershipMap(owner, newNFTPrincipal);
      Debug.print("Deployed successfully");
      return newNFTPrincipal;

    };
    private func addToMembershipMap(owner: Principal, nftId: Principal){
      var ownedNFTs :List.List<Principal> = switch(mapOfOwners.get(owner)) {
        case null List.nil<Principal>();
        case (?result) result;
      };
      ownedNFTs := List.push(nftId, ownedNFTs);
      mapOfOwners.put(owner, ownedNFTs);

    };
    public query func getOwnedNFTs(user : Principal) : async [Principal]{
      var userNFTs : List.List<Principal> = switch(mapOfOwners.get(user)){
        case null List.nil<Principal>();
        case (?result) result;
      };
      return List.toArray(userNFTs);
    };
    public query func getListedNFTs() : async [Principal] {
      let ids = Iter.toArray(mapofListings.keys());
      return ids;
    };

    public shared(msg) func listItem(id : Principal, price : Nat) : async Text{
      var item : NFTActorClass.NFT = switch ( mapOfNFTs.get(id)){
        case null return "NFT Does Not Exist";
        case (?result)  result;
      };

      let owner = await item.getOwner();
      if (Principal.equal(owner, msg.caller)){
        let newListing : Listing = {
          itemOwner = owner;
          itemPrice = price;
        };
        mapofListings.put(id, newListing);
        return "Success";
      } else {
        return "You dont Own the NFT";
      };
    };
    public query func getOpenDCanisterID() : async Principal{
      return Principal.fromActor(OpenD);
    };
    public query func isListed(id : Principal) : async Bool {
      if (mapofListings.get(id)==null){
        return false;
      };
      return true;
    };
    public query func getOriginalOwner(id : Principal) : async Principal{
      var listing : Listing = switch(mapofListings.get(id)){
        case null return Principal.fromText("");
        case (?result) result;
      };
      return listing.itemOwner;
    };
    public query func getListedNFTPrice(id : Principal) : async Nat {
      var listing : Listing = switch(mapofListings.get(id)){
        case null return 0;
        case (?result) result;
      };
      return listing.itemPrice;
    };
    public shared(msg) func completePurchase(id : Principal, ownerId : Principal, newOwnerId : Principal) : async Text {
      var purchasedNFT : NFTActorClass.NFT = switch(mapOfNFTs.get(id)){
        case null return "NFT Does Not Exist";
        case (?result) result;
      };

      let transferResult = await purchasedNFT.transferOwnership(newOwnerId);
      if(transferResult == "Success"){
        mapofListings.delete(id);
        var ownedNFTs : List.List<Principal> = switch(mapOfOwners.get(ownerId)){
          case null List.nil<Principal>();
          case (?result) result;
        };
        ownedNFTs := List.filter(ownedNFTs, func (listItemId:Principal) : Bool {
          return listItemId != id;
        });
        addToMembershipMap(newOwnerId, id);
        return "Success";
      } else {
        return "Error";
      };

    };

};
