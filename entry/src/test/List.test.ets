import localUnitTest from './LocalUnit.test';
import DataManagerTest from './DataManager.test';
import TransactionUtilsTest from './TransactionUtils.test';
import StatisticsCalculatorTest from './StatisticsCalculator.test';

export default function testsuite() {
  localUnitTest();
  DataManagerTest();
  TransactionUtilsTest();
  StatisticsCalculatorTest();
}