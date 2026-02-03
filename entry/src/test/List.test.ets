import localUnitTest from './LocalUnit.test';
import DataManagerTest from './DataManager.test';
import DataManagerHarmonyOSTest from './DataManagerHarmonyOSTest';
import DataManagerOptimizedTest from './DataManagerOptimizedTest';
import TransactionUtilsTest from './TransactionUtils.test';
import StatisticsCalculatorTest from './StatisticsCalculator.test';

export default function testsuite() {
  localUnitTest();
  DataManagerTest();
  DataManagerHarmonyOSTest();
  DataManagerOptimizedTest();
  TransactionUtilsTest();
  StatisticsCalculatorTest();
}