//---------------------------------------------------------------------------------------
//  FILE:    X2DLCInfo_TraversalChanger.uc
//  AUTHOR:  TRNEEDANAME
//  PURPOSE: The magic behind the sauce.
//---------------------------------------------------------------------------------------

class X2DLCInfo_TraversalChanger extends X2DownloadableContentInfo config (TraversalChanger_Adding);

struct native ClassData {
	var name ClassName;
	var name AbilityName;
	var int Rank;
};

struct native ItemData {
	var name ItemName;
	var name AbilityName;
};

struct native ArmourData {
	var name ArmourName;
	var name AbilityName;
};

struct native CharacterGroupData {
	var name CharacterGroupName;
	var name AbilityName;
};

struct native CharacterData {
	var name CharacterName;
	var name AbilityName;
};

var config array<ClassData> TraversalChanger_Classes;
var config array<ItemData> TraversalChanger_Item;
var config array<ArmourData> TraversalChanger_Armour;
var config array<CharacterGroupData> TraversalChanger_CharacterGroup;
var config array<CharacterData> TraversalChanger_Character;

var config(XComTraversalChange_Internal) bool bLog;

delegate ModifyTemplate(X2DataTemplate DataTemplate);

static event OnLoadedSavedGame()
{
	OnPostTemplatesCreated();
}

static event InstallNewCampaign(XComGameState StartState)
{
	OnPostTemplatesCreated();
}

static event OnPostTemplatesCreated()
{
    IterateTemplatesAllDiff(class'X2EquipmentTemplate', PatchEquipmentTemplates);
    IterateTemplatesAllDiff(class'X2EquipmentTemplate', PatchArmourTemplates);
	IterateTemplatesAllDiff(class'X2CharacterTemplate', PatchCharacterTemplates);
	IterateTemplatesAllDiff(class'X2CharacterTemplate', PatchCharacterGroupsTemplates);
	IterateTemplatesAllDiff(class'X2SoldierClassTemplate', PatchSoldierClassTemplates);
}

static function PatchEquipmentTemplates(X2DataTemplate DataTemplate)
{
	local X2EquipmentTemplate 	Template;
	local ItemData				ItemEntry;
	local bool					bIsTargetItem;

	Template = X2EquipmentTemplate(DataTemplate);
	if (Template == none)
	{
		return;
	}

	foreach default.TraversalChanger_Item(ItemEntry)
	{
		if (ItemEntry.ItemName == Template.DataName)
		{
			bIsTargetItem = true;
			break;
		}
	}

	if (!bIsTargetItem)
	{
		return;
	}

	`LOG("Patching equipment template with configured Traversal Changer abilities: " @ Template.DataName, default.bLog, 'Traversal Changer MOD ---');
	AddConfiguredPassiveAbilities(Template.Abilities, Template.DataName);
	AddConfiguredActiveAbilities(Template.Abilities, Template.DataName);
}

static function PatchArmourTemplates(X2DataTemplate DataTemplate)
{
	local X2ArmorTemplate		ArmourTemplate;
	local ArmourData			ArmourEntry;
	local bool					bIsTargetArmour;

	ArmourTemplate = X2ArmorTemplate(DataTemplate);
	if (ArmourTemplate == none)
	{
		return;
	}

	foreach default.TraversalChanger_Armour(ArmourEntry)
	{
		if (ArmourEntry.ArmourName == ArmourTemplate.DataName)
		{
			bIsTargetArmour = true;
			break;
		}
	}

	if (!bIsTargetArmour)
	{
		return;
	}

	`LOG("Patching armour template with configured Traversal Changer abilities: " @ ArmourTemplate.DataName, default.bLog, 'Traversal Changer MOD ---');
	AddConfiguredPassiveAbilities(ArmourTemplate.Abilities, ArmourTemplate.DataName);
	AddConfiguredActiveAbilities(ArmourTemplate.Abilities, ArmourTemplate.DataName);
}

static function PatchCharacterTemplates(X2DataTemplate DataTemplate)
{
	local X2CharacterTemplate	CharacterTemplate;
	local CharacterData			CharacterEntry;
	local bool					bIsTargetUnit;

	CharacterTemplate = X2CharacterTemplate(DataTemplate);
	if (CharacterTemplate == none)
	{
		return;
	}

	foreach default.TraversalChanger_Character(CharacterEntry)
	{
		if (CharacterTemplate.DataName == CharacterEntry.CharacterName)
		{
			bIsTargetUnit = true;
			break;
		}
	}

	if (!bIsTargetUnit)
	{
		return;
	}

	`LOG("Patching character template with configured Traversal Changer passive abilities: " @ CharacterTemplate.DataName, default.bLog, 'Traversal Changer MOD ---');
	AddConfiguredPassiveAbilities(CharacterTemplate.Abilities, CharacterTemplate.DataName);
}


static function PatchCharacterGroupsTemplates(X2DataTemplate DataTemplate)
{
	local X2CharacterTemplate	CharacterTemplate;
	local CharacterGroupData	CharacterGroupEntry;
	local bool					bIsTargetUnit;

	CharacterTemplate = X2CharacterTemplate(DataTemplate);
	if (CharacterTemplate == none)
	{
		return;
	}

	foreach default.TraversalChanger_CharacterGroup(CharacterGroupEntry)
	{
		if (CharacterTemplate.CharacterGroupName == CharacterGroupEntry.CharacterGroupName)
		{
			bIsTargetUnit = true;
			break;
		}
	}

	if (!bIsTargetUnit)
	{
		return;
	}

	`LOG("Patching character group template with configured Traversal Changer passive abilities: " @ CharacterTemplate.DataName, default.bLog, 'Traversal Changer MOD ---');
	AddConfiguredPassiveAbilities(CharacterTemplate.Abilities, CharacterTemplate.DataName);
}

static function PatchSoldierClassTemplates(X2DataTemplate DataTemplate)
{
	local X2SoldierClassTemplate	SoldierClassTemplate;
	local SoldierClassAbilitySlot	NewSlot;
	local array<name>				ActiveAbilityNames;
	local ClassData				ClassEntry;
	local name					AbilityName;
	local bool					bIsTargetClass;
	local int					SlotIndex;
	local int					RankIndex;

	SoldierClassTemplate = X2SoldierClassTemplate(DataTemplate);
	if (SoldierClassTemplate == none)
	{
		return;
	}

	foreach default.TraversalChanger_Classes(ClassEntry)
	{
		if (SoldierClassTemplate.DataName == ClassEntry.ClassName)
		{
			bIsTargetClass = true;
			break;
		}
	}

	if (!bIsTargetClass)
	{
		return;
	}

	if (SoldierClassTemplate.SoldierRanks.Length == 0)
	{
		return;
	}

	RankIndex = ClassEntry.Rank;
	if (RankIndex < 0 || RankIndex >= SoldierClassTemplate.SoldierRanks.Length)
	{
		RankIndex = 0;
	}

	ActiveAbilityNames = class'X2Ability_TraversalChanger'.static.GetActiveAbilityNames();
	foreach ActiveAbilityNames(AbilityName)
	{
		for (SlotIndex = 0; SlotIndex < SoldierClassTemplate.SoldierRanks[RankIndex].AbilitySlots.Length; ++SlotIndex)
		{
			if (SoldierClassTemplate.SoldierRanks[RankIndex].AbilitySlots[SlotIndex].AbilityType.AbilityName == AbilityName)
			{
				`LOG("Traversal Changer ability already exists in class: " @ SoldierClassTemplate.DisplayName @ " ability: " @ AbilityName, default.bLog, 'Traversal Changer MOD ---');
				break;
			}
		}

		if (SlotIndex == SoldierClassTemplate.SoldierRanks[RankIndex].AbilitySlots.Length)
		{
			NewSlot.AbilityType.AbilityName = AbilityName;
			SoldierClassTemplate.SoldierRanks[RankIndex].AbilitySlots.AddItem(NewSlot);
			`LOG("Added ability " @ AbilityName @ " to class: " @ SoldierClassTemplate.DisplayName, default.bLog, 'Traversal Changer MOD ---');
		}
	}
}

static private function AddConfiguredPassiveAbilities(out array<name> TargetAbilities, name TemplateName)
{
	local array<name>	PassiveAbilityNames;
	local name			AbilityName;

	PassiveAbilityNames = class'X2Ability_TraversalChanger'.static.GetPassiveAbilityNames();
	foreach PassiveAbilityNames(AbilityName)
	{
		if (TargetAbilities.Find(AbilityName) == INDEX_NONE)
		{
			TargetAbilities.AddItem(AbilityName);
			`LOG("Added passive ability " @ AbilityName @ " to template: " @ TemplateName, default.bLog, 'Traversal Changer MOD ---');
		}
	}
}

static private function AddConfiguredActiveAbilities(out array<name> TargetAbilities, name TemplateName)
{
	local array<name>	ActiveAbilityNames;
	local name			AbilityName;

	ActiveAbilityNames = class'X2Ability_TraversalChanger'.static.GetActiveAbilityNames();
	foreach ActiveAbilityNames(AbilityName)
	{
		if (TargetAbilities.Find(AbilityName) == INDEX_NONE)
		{
			TargetAbilities.AddItem(AbilityName);
			`LOG("Added active ability " @ AbilityName @ " to template: " @ TemplateName, default.bLog, 'Traversal Changer MOD ---');
		}
	}
}

// ============================================================
// ========================= HELPER ===========================
// ============================================================

static private function IterateTemplatesAllDiff(class TemplateClass, delegate<ModifyTemplate> ModifyTemplateFn)
{
    local X2DataTemplate                                    IterateTemplate;
    local X2DataTemplate                                    DataTemplate;
    local array<X2DataTemplate>                             DataTemplates;
    local X2DLCInfo_TraversalChanger CDO;

    local X2ItemTemplateManager             ItemMgr;
    local X2AbilityTemplateManager          AbilityMgr;
    local X2CharacterTemplateManager        CharMgr;
    local X2StrategyElementTemplateManager  StratMgr;
    local X2SoldierClassTemplateManager     ClassMgr;

    if (ClassIsChildOf(TemplateClass, class'X2ItemTemplate'))
    {
        CDO = GetCDO();
        ItemMgr = class'X2ItemTemplateManager'.static.GetItemTemplateManager();

        foreach ItemMgr.IterateTemplates(IterateTemplate)
        {
            if (!ClassIsChildOf(IterateTemplate.Class, TemplateClass)) continue;

            ItemMgr.FindDataTemplateAllDifficulties(IterateTemplate.DataName, DataTemplates);
            foreach DataTemplates(DataTemplate)
            {   
                CDO.CallModifyTemplateFn(ModifyTemplateFn, DataTemplate);
            }
        }
    }
    else if (ClassIsChildOf(TemplateClass, class'X2AbilityTemplate'))
    {
        CDO = GetCDO();
        AbilityMgr = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

        foreach AbilityMgr.IterateTemplates(IterateTemplate)
        {
            if (!ClassIsChildOf(IterateTemplate.Class, TemplateClass)) continue;

            AbilityMgr.FindDataTemplateAllDifficulties(IterateTemplate.DataName, DataTemplates);
            foreach DataTemplates(DataTemplate)
            {
                CDO.CallModifyTemplateFn(ModifyTemplateFn, DataTemplate);
            }
        }
    }
    else if (ClassIsChildOf(TemplateClass, class'X2CharacterTemplate'))
    {
        CDO = GetCDO();
        CharMgr = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();
        foreach CharMgr.IterateTemplates(IterateTemplate)
        {
            if (!ClassIsChildOf(IterateTemplate.Class, TemplateClass)) continue;

            CharMgr.FindDataTemplateAllDifficulties(IterateTemplate.DataName, DataTemplates);
            foreach DataTemplates(DataTemplate)
            {
                CDO.CallModifyTemplateFn(ModifyTemplateFn, DataTemplate);
            }
        }
    }
    else if (ClassIsChildOf(TemplateClass, class'X2StrategyElementTemplate'))
    {
        CDO = GetCDO();
        StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
        foreach StratMgr.IterateTemplates(IterateTemplate)
        {
            if (!ClassIsChildOf(IterateTemplate.Class, TemplateClass)) continue;

            StratMgr.FindDataTemplateAllDifficulties(IterateTemplate.DataName, DataTemplates);
            foreach DataTemplates(DataTemplate)
            {
                CDO.CallModifyTemplateFn(ModifyTemplateFn, DataTemplate);
            }
        }
    }
    else if (ClassIsChildOf(TemplateClass, class'X2SoldierClassTemplate'))
    {

        CDO = GetCDO();
        ClassMgr = class'X2SoldierClassTemplateManager'.static.GetSoldierClassTemplateManager();
        foreach ClassMgr.IterateTemplates(IterateTemplate)
        {
            if (!ClassIsChildOf(IterateTemplate.Class, TemplateClass)) continue;

            ClassMgr.FindDataTemplateAllDifficulties(IterateTemplate.DataName, DataTemplates);
            foreach DataTemplates(DataTemplate)
            {
                CDO.CallModifyTemplateFn(ModifyTemplateFn, DataTemplate);
            }
        }
    }    
}

static private function ModifyTemplateAllDiff(name TemplateName, class TemplateClass, delegate<ModifyTemplate> ModifyTemplateFn)
{
    local X2DataTemplate                                    DataTemplate;
    local array<X2DataTemplate>                             DataTemplates;
    local X2DLCInfo_TraversalChanger    CDO;

    local X2ItemTemplateManager             ItemMgr;
    local X2AbilityTemplateManager          AbilityMgr;
    local X2CharacterTemplateManager        CharMgr;
    local X2StrategyElementTemplateManager  StratMgr;
    local X2SoldierClassTemplateManager     ClassMgr;

    if (ClassIsChildOf(TemplateClass, class'X2ItemTemplate'))
    {
        ItemMgr = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
        ItemMgr.FindDataTemplateAllDifficulties(TemplateName, DataTemplates);
    }
    else if (ClassIsChildOf(TemplateClass, class'X2AbilityTemplate'))
    {
        AbilityMgr = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
        AbilityMgr.FindDataTemplateAllDifficulties(TemplateName, DataTemplates);
    }
    else if (ClassIsChildOf(TemplateClass, class'X2CharacterTemplate'))
    {
        CharMgr = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();
        CharMgr.FindDataTemplateAllDifficulties(TemplateName, DataTemplates);
    }
    else if (ClassIsChildOf(TemplateClass, class'X2StrategyElementTemplate'))
    {
        StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
        StratMgr.FindDataTemplateAllDifficulties(TemplateName, DataTemplates);
    }
    else if (ClassIsChildOf(TemplateClass, class'X2SoldierClassTemplate'))
    {
        ClassMgr = class'X2SoldierClassTemplateManager'.static.GetSoldierClassTemplateManager();
        ClassMgr.FindDataTemplateAllDifficulties(TemplateName, DataTemplates);
    }
    else return;

    CDO = GetCDO();
    foreach DataTemplates(DataTemplate)
    {
        CDO.CallModifyTemplateFn(ModifyTemplateFn, DataTemplate);
    }
}

static private function X2DLCInfo_TraversalChanger GetCDO()
{
    return X2DLCInfo_TraversalChanger(class'XComEngine'.static.GetClassDefaultObjectByName(default.Class.Name));
}

protected function CallModifyTemplateFn(delegate<ModifyTemplate> ModifyTemplateFn, X2DataTemplate DataTemplate)
{
    ModifyTemplateFn(DataTemplate);
}