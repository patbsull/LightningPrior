public class CentralTendency {
	
    public static Map<Double, Double> getClusters(List<Double> numbers){
        Map<Integer,Map<Double, Double>> groups = new Map<Integer,Map<Double, Double>>();
        Map<Double, Double> best = new Map<Double, Double>();
        numbers.sort();
        
        if(numbers.size()>=10){
            for(Integer i = 1; i <= numbers.size()/3 ; i++ ){
                groups.put( i, clusterNumbers(i,numbers) );
            }
        }
        
        return best;
    } 
    
    private static Map<Double,Double> clusterNumbers(Integer numberOfGroups, List<Double> numbers){
        Map<Double,Double> winner = new Map<Double,Double>();
        for(Integer i = 0; i<numbers.size(); i++){
            
        }
        return winner;
    }
    
    private class clusters {
        
    }
}