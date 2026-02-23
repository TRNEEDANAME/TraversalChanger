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
	local name					AbilityToAdd;

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
			AbilityToAdd = ItemEntry.AbilityName;
			break;
		}
	}

	if (!bIsTargetItem)
	{
		return;
	}

	`LOG("Patching equipment template with configured Traversal Changer abilities: " @ Template.DataName, default.bLog, 'TraversalChanger');
	AddAbility(Template.Abilities, AbilityToAdd, Template.DataName);
}

static function PatchArmourTemplates(X2DataTemplate DataTemplate)
{
	local X2ArmorTemplate		ArmourTemplate;
	local ArmourData			ArmourEntry;
	local bool					bIsTargetArmour;
	local name					AbilityToAdd;

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
			AbilityToAdd = ArmourEntry.AbilityName;
			break;
		}
	}

	if (!bIsTargetArmour)
	{
		return;
	}

	`LOG("Patching armour template with configured Traversal Changer abilities: " @ ArmourTemplate.DataName, default.bLog, 'TraversalChanger');
	AddAbility(ArmourTemplate.Abilities, AbilityToAdd, ArmourTemplate.DataName);
}

static function PatchCharacterTemplates(X2DataTemplate DataTemplate)
{
	local X2CharacterTemplate	CharacterTemplate;
	local CharacterData			CharacterEntry;
	local bool					bIsTargetUnit;
	local name					AbilityToAdd;

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
			AbilityToAdd = CharacterEntry.AbilityName;
			break;
		}
	}

	if (!bIsTargetUnit)
	{
		return;
	}

	`LOG("Patching character template with configured Traversal Changer passive abilities: " @ CharacterTemplate.DataName, default.bLog, 'TraversalChanger');
	AddAbility(CharacterTemplate.Abilities, AbilityToAdd, CharacterTemplate.DataName);
}


static function PatchCharacterGroupsTemplates(X2DataTemplate DataTemplate)
{
	local X2CharacterTemplate	CharacterTemplate;
	local CharacterGroupData	CharacterGroupEntry;
	local bool					bIsTargetUnit;
	local name					AbilityToAdd;

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
			AbilityToAdd = CharacterGroupEntry.AbilityName;
			break;
		}
	}

	if (!bIsTargetUnit)
	{
		return;
	}

	`LOG("Patching character group template with configured Traversal Changer passive abilities: " @ CharacterTemplate.DataName, default.bLog, 'TraversalChanger');
	AddAbility(CharacterTemplate.Abilities, AbilityToAdd, CharacterTemplate.DataName);
}

static function PatchSoldierClassTemplates(X2DataTemplate DataTemplate)
{
	local X2SoldierClassTemplate	SoldierClassTemplate;
	local SoldierClassAbilitySlot	NewSlot;
	local ClassData				ClassEntry;
	local name					AbilityToAdd;
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

	AbilityToAdd = ClassEntry.AbilityName;
	if (AbilityToAdd == '')
	{
		return;
	}

	for (SlotIndex = 0; SlotIndex < SoldierClassTemplate.SoldierRanks[RankIndex].AbilitySlots.Length; ++SlotIndex)
	{
		if (SoldierClassTemplate.SoldierRanks[RankIndex].AbilitySlots[SlotIndex].AbilityType.AbilityName == AbilityToAdd)
		{
			`LOG("Traversal Changer ability already exists in class: " @ SoldierClassTemplate.DisplayName @ " ability: " @ AbilityToAdd, default.bLog, 'TraversalChanger');
			break;
		}
	}

	if (SlotIndex == SoldierClassTemplate.SoldierRanks[RankIndex].AbilitySlots.Length)
	{
		NewSlot.AbilityType.AbilityName = AbilityToAdd;
		SoldierClassTemplate.SoldierRanks[RankIndex].AbilitySlots.AddItem(NewSlot);
		`LOG("Added ability " @ AbilityToAdd @ " to class: " @ SoldierClassTemplate.DisplayName, default.bLog, 'TraversalChanger');
	}
}

static private function AddAbility(out array<name> TargetAbilities, name AbilityName, name TemplateName)
{
	if (AbilityName == '')
	{
		return;
	}

	if (TargetAbilities.Find(AbilityName) == INDEX_NONE)
	{
		TargetAbilities.AddItem(AbilityName);
		`LOG("Added ability " @ AbilityName @ " to template: " @ TemplateName, default.bLog, 'TraversalChanger');
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