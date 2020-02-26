public with sharing class ExecuteNeeded {
	private static Set<string> alreadyRan = new Set<string>();
	public static boolean OnTrigger(string tname)
	{
		if (alreadyRan.contains(tname))
		{
			system.debug('ExecuteNeeded: '+tname+' Value: false');
			return false;
		}
		else
		{
			system.debug('ExecuteNeeded: '+tname+' Value: true');
			alreadyRan.add(tname);
			return true;
		}	
	}
}