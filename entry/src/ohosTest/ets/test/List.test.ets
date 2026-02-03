import abilityTest from './Ability.test';
import IndexPageTest from './IndexPage.test';
import AddTransactionDialogTest from './AddTransactionDialog.test';
import StatisticsPageTest from './StatisticsPage.test';
import DataFlowTest from './DataFlow.test';

export default function testsuite() {
  abilityTest();
  IndexPageTest();
  AddTransactionDialogTest();
  StatisticsPageTest();
  DataFlowTest();
}