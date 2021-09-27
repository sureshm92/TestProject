/**
 * Created by Leonid Bartenev for testing
 */

public without sharing class Path {
    public enum PathState {
        success,
        failure,
        in_progress,
        neutral
    }

    public class PathItem {
        @AuraEnabled
        public PathState left;
        @AuraEnabled
        public PathState right;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public PathState state;
        @AuraEnabled
        public Boolean isCurrent;
    }

    public static List<PathItem> generatePath(List<String> steps, String currentStep) {
        List<PathItem> pathItems = new List<Path.PathItem>();
        Integer currentIndex = 100;
        for (Integer i = 0; i < steps.size(); i++) {
            if (currentStep == steps[i]) {
                currentIndex = i;
                break;
            }
        }
        for (Integer i = 0; i < steps.size(); i++) {
            PathItem item = new PathItem();
            item.name = steps[i];
            item.left = PathState.neutral;
            item.right = PathState.neutral;
            item.state = PathState.neutral;
            item.isCurrent = i == currentIndex;
            if (i <= currentIndex) {
                item.left = PathState.success;
                item.state = PathState.success;
                if (i != currentIndex)
                    item.right = PathState.success;
            }
            pathItems.add(item);
        }
        return pathItems;
    }
}
