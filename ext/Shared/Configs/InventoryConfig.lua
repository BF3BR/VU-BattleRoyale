---@class InventoryConfig
InventoryConfig = {
	-- how frequently the close item cache should be updated (seconds)
	CloseItemCacheFrequency = 5.0,

	-- the radius that the search is done for caching close items
	CloseItemCacheRadius = 50,

	-- the radius around the player to search for close items (client)
	CloseItemSearchRadiusClient = 2.8,

	-- the radius around the player that he is allowed to pickup items
	-- better give it some extra compared to `CloseItemSearchRadiusClient`
	CloseItemAllowedRadiusServer = 3.5,
}
