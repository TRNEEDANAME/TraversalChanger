//---------------------------------------------------------------------------------------
//  FILE:    X2Ability_TraversalChanger.uc
//  AUTHOR:  TRNEEDANAME
//  PURPOSE: Create abilities that change traversal
//---------------------------------------------------------------------------------------

class X2Ability_TraversalChanger extends X2Ability config (TraversalChanger_Ability);

struct native PassiveAbilityData {
    var name AbilityTemplateName;
	var string AbilityName;
    var string IconPath;
    var name EffectName;
	var name Change;
	var bool RemoveTraversal;
	var string Description;

	structdefaultproperties
	{
		IconPath = "UILibrary_PerkIcons.UIPerk_absorption_fields";
	}
};

struct native ActiveAbilityData {
    var name AbilityTemplateName;
	var string AbilityName;
    var string IconPath;
    var name EffectName;
	var name Change;
	var string Description;
	var int NumTurns;
	var int AP_Cost;
	var bool IsFree;
	var bool ConsumeAllPoints;
	var int Cooldown;
	var bool HasCharge;
	var int InitialCharge;
	structdefaultproperties
	{
		IconPath = "UILibrary_PerkIcons.UIPerk_absorption_fields";
		 NumTurns = 2;
		 AP_Cost = 1;
		IsFree = false;
		ConsumeAllPoints = false;
		Cooldown = 1;
		HasCharge = false;
		InitialCharge = 2;
	}
};

var config array<PassiveAbilityData> PassiveAbilities;
var config array<ActiveAbilityData> ActiveAbilities;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	local PassiveAbilityData PassiveAbilityConfig;
	local ActiveAbilityData ActiveAbilityConfig;

	foreach default.PassiveAbilities (PassiveAbilityConfig) {
		Templates.AddItem(TR_TraversalChanger_Passive(PassiveAbilityConfig));
	}

	foreach default.ActiveAbilities (ActiveAbilityConfig) {
		Templates.AddItem(TR_TraversalChanger_Active(ActiveAbilityConfig));
	}

	return Templates;
}

static function X2AbilityTemplate TR_TraversalChanger_Passive(PassiveAbilityData PassiveAbilityConfig)
{

	local X2AbilityTemplate								Template;
	local X2Effect_PersistentTraversalChange		TraversalEffect;

	Template = CreatePassiveAbility(PassiveAbilityConfig.AbilityTemplateName, "img:///" $ PassiveAbilityConfig.IconPath);

	TraversalEffect = new class'X2Effect_PersistentTraversalChange';
	TraversalEffect.AddTraversalChange(MapTraversalType(PassiveAbilityConfig.Change), PassiveAbilityConfig.RemoveTraversal);
	TraversalEffect.EffectName = PassiveAbilityConfig.EffectName;
	TraversalEffect.DuplicateResponse = eDupe_Ignore;
	TraversalEffect.BuildPersistentEffect(5, true, true, false, eGameRule_PlayerTurnBegin);
	if (PassiveAbilityConfig.AbilityName == "") {
		TraversalEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage,,,Template.AbilitySourceName);
	}
	else {
		TraversalEffect.SetDisplayInfo(ePerkBuff_Passive, PassiveAbilityConfig.AbilityName, PassiveAbilityConfig.Description, Template.IconImage,,,Template.AbilitySourceName);
	}

	Template.AddTargetEffect(TraversalEffect);

	return Template;
}

static function X2AbilityTemplate TR_TraversalChanger_Active(ActiveAbilityData ActiveAbilityConfig)
{
	local X2AbilityTemplate						Template;
	local X2Effect_PersistentTraversalChange    TraversalEffect;
	local X2AbilityCost_ActionPoints    	ActionPointCost;
	local X2AbilityCooldown             	Cooldown;
	local X2AbilityCharges              	Charges;
	local X2AbilityCost_Charges         	ChargeCost;

	`CREATE_X2ABILITY_TEMPLATE(Template, ActiveAbilityConfig.AbilityTemplateName);

	//setup
	Template.IconImage = "img:///" $ ActiveAbilityConfig.IconPath;
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_HideSpecificErrors;
	Template.HideErrors.AddItem('AA_UnitIsNotImpaired');
	Template.HideErrors.AddItem('AA_AbilityUnavailable');
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";
	if (ActiveAbilityConfig.IsFree) {
		Template.AbilitySourceName = 'eAbilitySource_Commander';
	}
	else {
		Template.AbilitySourceName = 'eAbilitySource_Perk';
	}
	Template.Hostility = eHostility_Neutral;
	Template.ShotHUDPriority = 9999;
	
	Template.bDisplayInUITacticalText = true;
	Template.bDontDisplayInAbilitySummary = false;

	Template.bDisplayInUITooltip = true;

	Template.bUniqueSource = true;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = ActiveAbilityConfig.AP_Cost;
	ActionPointCost.bFreeCost = ActiveAbilityConfig.IsFree;
	ActionPointCost.bConsumeAllPoints = ActiveAbilityConfig.ConsumeAllPoints;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Cooldown = new class'X2AbilityCooldown';   
	Cooldown.iNumTurns = ActiveAbilityConfig.Cooldown; 
	Template.AbilityCooldown = Cooldown;

	if (ActiveAbilityConfig.HasCharge)
	{
		Charges = new class'X2AbilityCharges';
		Charges.InitialCharges = ActiveAbilityConfig.InitialCharge;
		Template.AbilityCharges = Charges;
	
		ChargeCost = new class'X2AbilityCost_Charges';
		ChargeCost.NumCharges = 1;
		Template.AbilityCosts.AddItem(ChargeCost);

	}

	//targeting
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	//Conditional
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	TraversalEffect = new class'X2Effect_PersistentTraversalChange';
	TraversalEffect.AddTraversalChange(MapTraversalType(ActiveAbilityConfig.Change), true);
	TraversalEffect.EffectName = ActiveAbilityConfig.EffectName;
	TraversalEffect.DuplicateResponse = eDupe_Ignore;
	TraversalEffect.BuildPersistentEffect(ActiveAbilityConfig.NumTurns, false, true, false, eGameRule_PlayerTurnBegin);
	if (ActiveAbilityConfig.AbilityName == "") {
		TraversalEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage,,,Template.AbilitySourceName);
	}
	else {
		TraversalEffect.SetDisplayInfo(ePerkBuff_Passive, ActiveAbilityConfig.AbilityName, ActiveAbilityConfig.Description, Template.IconImage,,,Template.AbilitySourceName);
	}
	Template.AddTargetEffect(TraversalEffect);

	//ability visualization
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	
	Template.bStationaryWeapon = true;

	return Template;
}

// ======================
// HELPER
// ======================

static function ETraversalType MapTraversalType(name TraversalName)
{
	switch (TraversalName)
	{
		case 'eTraversal_Normal':
			return eTraversal_Normal;
		case 'eTraversal_ClimbOver':
			return eTraversal_ClimbOver;
		case 'eTraversal_ClimbOnto':
			return eTraversal_ClimbOnto;
		case 'eTraversal_ClimbLadder':
			return eTraversal_ClimbLadder;
		case 'eTraversal_DropDown':
			return eTraversal_DropDown;
		case 'eTraversal_Grapple':
			return eTraversal_Grapple;
		case 'eTraversal_Landing':
			return eTraversal_Landing;
		case 'eTraversal_BreakWindow':
			return eTraversal_BreakWindow;
		case 'eTraversal_KickDoor':
			return eTraversal_KickDoor;
		case 'eTraversal_WallClimb':
			return eTraversal_WallClimb;
		case 'eTraversal_JumpUp':
			return eTraversal_JumpUp;
		case 'eTraversal_Ramp':
			return eTraversal_Ramp;
		case 'eTraversal_BreakWall':
			return eTraversal_BreakWall;
		case 'eTraversal_Phasing':
			return eTraversal_Phasing;
		case 'eTraversal_Launch':
			return eTraversal_Launch;
		case 'eTraversal_Flying':
			return eTraversal_Flying;
		case 'eTraversal_Land':
			return eTraversal_Land;
		case 'eTraversal_Teleport':
			return eTraversal_Teleport;
		case 'eTraversal_Unreachable':
			return eTraversal_Unreachable;
		case 'eTraversal_None':
		default:
			return eTraversal_None;
	}
}

static function array<name> GetPassiveAbilityNames()
{
	local array<name> AbilityNames;
	local PassiveAbilityData PassiveAbilityConfig;

	foreach default.PassiveAbilities(PassiveAbilityConfig)
	{
		if (AbilityNames.Find(PassiveAbilityConfig.AbilityTemplateName) == INDEX_NONE)
		{
			AbilityNames.AddItem(PassiveAbilityConfig.AbilityTemplateName);
		}
	}

	return AbilityNames;
}

static function array<name> GetActiveAbilityNames()
{
	local array<name> AbilityNames;
	local ActiveAbilityData ActiveAbilityConfig;

	foreach default.ActiveAbilities(ActiveAbilityConfig)
	{
		if (AbilityNames.Find(ActiveAbilityConfig.AbilityTemplateName) == INDEX_NONE)
		{
			AbilityNames.AddItem(ActiveAbilityConfig.AbilityTemplateName);
		}
	}

	return AbilityNames;
}

static function X2AbilityTemplate CreatePassiveAbility(name AbilityName, optional string IconString, optional name IconEffectName = AbilityName, optional bool bDisplayIcon = true)
{
	
	local X2AbilityTemplate					Template;
	local X2Effect_Persistent				IconEffect;
	

	`CREATE_X2ABILITY_TEMPLATE (Template, AbilityName);
	Template.IconImage = IconString;
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	Template.bCrossClassEligible = false;
	Template.bUniqueSource = true;
	Template.bIsPassive = true;

	// Dummy effect to show a passive icon in the tactical UI for the SourceUnit
	IconEffect = new class'X2Effect_Persistent';
	IconEffect.BuildPersistentEffect(1, true, false);
	IconEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocHelpText, Template.IconImage, bDisplayIcon,, Template.AbilitySourceName);
	IconEffect.EffectName = IconEffectName;
	Template.AddTargetEffect(IconEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	return Template;
}
