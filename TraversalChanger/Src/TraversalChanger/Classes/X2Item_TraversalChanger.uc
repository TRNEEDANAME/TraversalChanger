//---------------------------------------------------------------------------------------
//  FILE:    X2Item_TraversalChanger.uc
//  AUTHOR:  TRNEEDANAME
//  PURPOSE: Create Traversal Changer utility items and vests from config.
// Yes this whole thing can be done using Template Master but... Anyway
//---------------------------------------------------------------------------------------

class X2Item_TraversalChanger extends X2Item config (TraversalChanger_Items);

struct native TraversalVestBonusData
{
	var name BonusStatType;
	var int BonusValue;

	structdefaultproperties
	{
		BonusStatType = eStat_None;
		BonusValue = 0;
	}
};

struct native TraversalItemData
{
	var bool Enabled;
	var name TemplateName;
	var name ItemName;
	var string ImagePath;
	var name AbilityName;
	var array<name> AbilityNames;
	var bool CanBeBuilt;
	var bool StartingItem;
	var bool InfiniteItem;
	var int TradeValue;
	var int Cost;
	var int Tier;
};

struct native TraversalVestData
{
	var bool Enabled;
	var name TemplateName;
	var string ImagePath;
	var name AbilityName;
	var array<name> AbilityNames;
	var bool CanBeBuilt;
	var bool StartingItem;
	var bool InfiniteItem;
	var int TradeValue;
	var int Cost;
	var int Tier;
	var array<TraversalVestBonusData> Bonuses;
	var bool AddExperimentalArmorRewards;
};

var config array<TraversalItemData> TraversalItems;
var config array<TraversalVestData> TraversalVests;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	local TraversalItemData ItemData;
	local TraversalVestData VestData;

	foreach default.TraversalItems(ItemData)
	{
		if (ItemData.Enabled)
		{
			Templates.AddItem(CreateTraversalItemTemplate(ItemData));
		}
	}

	foreach default.TraversalVests(VestData)
	{
		if (VestData.Enabled)
		{
			Templates.AddItem(CreateTraversalVestTemplate(VestData));
		}
	}

	return Templates;
}

static function X2DataTemplate CreateTraversalItemTemplate(TraversalItemData ItemData)
{
	local X2EquipmentTemplate Template;
	local ArtifactCost Resources;

	`CREATE_X2TEMPLATE(class'X2EquipmentTemplate', Template, ItemData.TemplateName);

	Template.strImage = "img:///" $ ItemData.ImagePath;
	Template.ItemCat = 'defense';
	Template.InventorySlot = eInvSlot_Utility;
	Template.EquipSound = "StrategyUI_Medkit_Equip";

	AddConfiguredAbilities(Template.Abilities, ItemData.AbilityName, ItemData.AbilityNames);

	Template.CanBeBuilt = ItemData.CanBeBuilt;
	Template.StartingItem = ItemData.StartingItem;
	Template.bInfiniteItem = ItemData.InfiniteItem;
	Template.Tier = ItemData.Tier;

    // For now only supplies but the cost can be changed using StrategyTuning.ini
	if (!ItemData.InfiniteItem)
	{
		Template.TradingPostValue = ItemData.TradeValue;
		Resources.ItemTemplateName = 'Supplies';
		Resources.Quantity = ItemData.Cost;
		Template.Cost.ResourceCosts.AddItem(Resources);
		Template.bShouldCreateDifficultyVariants = true;
	}

	return Template;
}

static function X2DataTemplate CreateTraversalVestTemplate(TraversalVestData VestData)
{
	local X2EquipmentTemplate Template;
	local ArtifactCost Resources;
	local TraversalVestBonusData BonusData;

	`CREATE_X2TEMPLATE(class'X2EquipmentTemplate', Template, VestData.TemplateName);

	Template.strImage = "img:///" $ VestData.ImagePath;
	Template.ItemCat = 'defense';
	Template.InventorySlot = eInvSlot_Utility;
	Template.EquipSound = "StrategyUI_Vest_Equip";

	AddConfiguredAbilities(Template.Abilities, VestData.AbilityName, VestData.AbilityNames);

	Template.CanBeBuilt = VestData.CanBeBuilt;
	Template.StartingItem = VestData.StartingItem;
	Template.bInfiniteItem = VestData.InfiniteItem;
	Template.Tier = VestData.Tier;
	Template.PointsToComplete = 0;

	if (!VestData.InfiniteItem)
	{
		Template.TradingPostValue = VestData.TradeValue;
		Resources.ItemTemplateName = 'Supplies';
		Resources.Quantity = VestData.Cost;
		Template.Cost.ResourceCosts.AddItem(Resources);
	}

	if (VestData.AddExperimentalArmorRewards)
	{
		Template.RewardDecks.AddItem('ExperimentalArmorRewards');
	}

	foreach VestData.Bonuses(BonusData)
	{
		ApplyVestBonus(Template, BonusData.BonusStatType, BonusData.BonusValue);
	}

	return Template;
}

// =============================
// HELPER
// =============================

static function ApplyVestBonus(X2EquipmentTemplate Template, name BonusStatType, int BonusValue)
{
	local ECharStatType StatType;
	local string StatLabel;

	if (BonusValue == 0)
	{
		return;
	}

	if (!TryMapVestBonusStat(BonusStatType, StatType, StatLabel))
	{
		return;
	}

	Template.SetUIStatMarkup(StatLabel, StatType, BonusValue);
}

// Primary ability is the Traversal change, the rest are just if the player want more butter with the steak
static function AddConfiguredAbilities(out array<name> TemplateAbilities, name PrimaryAbility, array<name> AdditionalAbilities)
{
	local name AbilityName;

	if (PrimaryAbility != '' && TemplateAbilities.Find(PrimaryAbility) == INDEX_NONE)
	{
		TemplateAbilities.AddItem(PrimaryAbility);
	}

	foreach AdditionalAbilities(AbilityName)
	{
		if (AbilityName != '' && TemplateAbilities.Find(AbilityName) == INDEX_NONE)
		{
			TemplateAbilities.AddItem(AbilityName);
		}
	}
}

// I have no clue if it's the best way, but doing it any other way would mean a very long and tedious code spaghetti
static function bool TryMapVestBonusStat(name BonusStatType, out ECharStatType StatType, out string StatLabel)
{
	switch (BonusStatType)
	{
		case 'eStat_HP':
			StatType = eStat_HP;
			StatLabel = class'XLocalizedData'.default.HealthLabel;
			return true;

		case 'eStat_Offense':
			StatType = eStat_Offense;
			StatLabel = class'XLocalizedData'.default.AimLabel;
			return true;

		case 'eStat_Will':
			StatType = eStat_Will;
			StatLabel = class'XLocalizedData'.default.WillLabel;
			return true;

		case 'eStat_Mobility':
			StatType = eStat_Mobility;
			StatLabel = class'XLocalizedData'.default.MobilityLabel;
			return true;

		case 'eStat_Hacking':
			StatType = eStat_Hacking;
			StatLabel = class'XLocalizedData'.default.TechLabel;
			return true;

		case 'eStat_ArmorMitigation':
			StatType = eStat_ArmorMitigation;
			StatLabel = class'XLocalizedData'.default.ArmorLabel;
			return true;

		case 'eStat_Dodge':
			StatType = eStat_Dodge;
			StatLabel = class'XLocalizedData'.default.DodgeLabel;
			return true;

		case 'eStat_Defense':
			StatType = eStat_Defense;
			StatLabel = class'XLocalizedData'.default.DefenseLabel;
			return true;

		case 'eStat_PsiOffense':
			StatType = eStat_PsiOffense;
			StatLabel = class'XLocalizedData'.default.PsiOffenseLabel;
			return true;

		default:
			return false;
	}
}
