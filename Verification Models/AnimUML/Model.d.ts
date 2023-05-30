// These definitions are still incomplete

export interface Model<IsInMemory extends boolean> {
	name: string
	objects: ModelObject<IsInMemory>[]
	classes?:	IsInMemory extends true
			?	{[clName : string]: Classifier}	// in-memory
			:	string				// exported
	isActive?: (o : Object) => boolean		// present in-memory, absent exported
	connectorByName?: {[conName : string] : Connector<IsInMemory>}
	interactions?: {[interName : string]: IsInMemory extends true ? Interaction : string}
	watchExpressions?: {[name : string]: string}
	LTLProperties?: {[name : string]: string}
	settings?: Settings
}

export interface Settings {
	display?: Partial<DisplaySettings>
	semantics?: Partial<SemanticsSettings>
	interface?: Partial<InterfaceSettings>
}

export interface DisplaySettings {
	showComments: boolean
	hideLinks: boolean
	showClassDiagram: boolean

	// structural diagram
	hideClasses: boolean
	hideOperations: boolean
	hideMethods: boolean
	showPorts: boolean
	showEndNames: boolean
	showEventPools: boolean
	hidePackages: boolean
	showMethodsAsActivities: boolean
	showActorsAsObjects: boolean

	 // state diagram
	hideStateMachines: boolean
	hideOuterSMBoxes: boolean
	showExplicitSM: boolean

	// history/trace interaction diagram
	hideStates: boolean
	showPseudostateInvariants: boolean
	hideSets: boolean
	showTransitions: boolean
}

export interface SemanticsSettings {
	fireInitialTransitions: boolean
	autoFireAfterChoice: boolean
	autoReceiveDisabled: boolean
	considerGuardsTrue: boolean
	checkEvents: boolean
	keepOneMessagePerTrigger: boolean
	enableEventPools: boolean
	matchFirst: boolean
	symbolicValues: boolean
	reactiveSystem: boolean
	synchronousCommunication: boolean
	withDBM: boolean
}

export interface InterfaceSettings {
	hideEmptyHistory: boolean
	disableInteractionSelection: boolean
	disableModelSelection: boolean
	disableObjectSelection: boolean
	disableDoc: boolean
	disableSettings: boolean
	disableHistorySettings: boolean
	disableReset: boolean
	disableSwitchDiagram: boolean
	onlyInteraction: boolean
	hideInteraction: boolean
	disableExports: boolean
	hideHistory: boolean
	disableEdit: boolean
	historyType: "TCSVG sequence" | "sequence" | "timing"
	interaction: string
	mainWidth: string
	histWidth: string
	displayedObjects?: string[]
}

export interface State<IsInMemory extends boolean> extends Partial<Region<IsInMemory>> {
	name?: string
	type?: string
	kind?: string
	entry?: string
	exit?: string
	doActivity?: string
	internalTransitions?: {[transName: string]: Partial<Transition<IsInMemory>>}
}

export interface Transition<IsInMemory extends boolean> {
	name?: string
	trigger?: string
	guard?: string
	effect?: string
	source:	IsInMemory extends true
		?	State<IsInMemory>	// in-memory
		:	string			// exported
	target:	IsInMemory extends true
		?	State<IsInMemory>	// in-memory
		:	string			// exported
}

type Transitions<IsInMemory extends boolean> = {[transName: string]: Transition<IsInMemory>}
type States<IsInMemory extends boolean> = {[stateName : string]: State<IsInMemory>}

export interface Region<IsInMemory extends boolean> {
	stateByName: States<IsInMemory>
	transitionByName: Transitions<IsInMemory>
}

export interface Parameter {
	name: string
	type: string
}

export interface Operation {
	name?: string
	method?: string
	returnType?: string
	parameters?: (Parameter | string)[]
	isOperation?: boolean
	private?: boolean
}

export interface Property {
	name?: string
	type?: string
	defaultValue?: any
	comment?: string
}

export interface Featured {
	operationByName: {[opName : string]: Operation}
	propertyByName: {[propName : string]: Property}
}

export interface Interaction {
	// TODO
	events: any[]
}

export interface ModelObject<IsInMemory extends boolean> extends Partial<Region<IsInMemory>>, Partial<Featured> {
	name: string
	class?: string
	isActor?: boolean
	isObserver?: boolean
	behavior?: string	// exported only
	features?: string	// exported only
	type?: "Port"
	packagePath?: string[]
	stereotypes?: string[]
}

export interface Classifier {
	name?: string
	stereotypes?: string[]

	// TODO: make inheritance work for the following optional properties?
	// For Association
	ends?: AssociationEnd[]
	// For Enumeration
	literals?: string[]
}

export interface Association extends Classifier {
	ends: AssociationEnd[]
}

export interface Enumeration extends Classifier {
	literals: string[]
}

export interface AssociationEnd {
	name?: string
	type: Classifier
}

export interface PossibleMessages {
	forward?: string[]
	reverse?: string[]
}

export interface Connector<IsInMemory extends boolean> {
	name?: string					// mandatory in-memory, optional exported
	ends?:	IsInMemory extends true			// only optional for exported models
		?	ModelObject<IsInMemory>[]	// for in-memory models
		:	string[]			// for exported models
	endNames?: string[]
	incomingTag?: string
	possibleMessages?: PossibleMessages
}

declare global {
	var examples: (Model<false> | ModelObject<false>)[]
}
