import router from '@ohos.router'
import { DataManager } from '../services/DataManager'
import { BottomNavBar } from '../components/BottomNavBar'

@Entry
@Component
struct Profile {
  @State transactionCount: number = 0
  @State categoryCount: number = 0
  private dataManager: DataManager = DataManager.getInstance()

  async aboutToAppear(): Promise<void> {
    const transactions = await this.dataManager.getTransactions()
    const categories = await this.dataManager.getCategories()
    this.transactionCount = transactions.length
    this.categoryCount = categories.length
  }

  build() {
    Stack() {
      Column() {
        this.Header()
        this.StatsSection()
        this.MenuSection()
        
        // 底部占位，给导航栏留出空间
        Blank()
          .height(56)
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#FAFAFA')

      // 底部导航栏固定在底部
      Column() {
        BottomNavBar({ currentPageIndex: 3 })
      }
      .width('100%')
      .height(56)
      .position({ x: 0, y: '100%' })
      .translate({ y: -56 })
      .zIndex(100)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  Header() {
    Column() {
      Text('👤')
        .fontSize(64)
        .margin({ bottom: 12 })
      
      Text('记账用户')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A1A1A')
        .margin({ bottom: 4 })
      
      Text('让记账变得简单')
        .fontSize(14)
        .fontColor('#757575')
    }
    .width('100%')
    .padding(32)
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Center)
    .margin({ bottom: 12 })
  }

  @Builder
  StatsSection() {
    Row() {
      this.StatItem('记账笔数', this.transactionCount.toString())
      Divider()
        .vertical(true)
        .height(40)
        .color('#EEEEEE')
      this.StatItem('分类数量', this.categoryCount.toString())
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .justifyContent(FlexAlign.SpaceEvenly)
    .margin({ bottom: 12 })
  }

  @Builder
  StatItem(label: string, value: string) {
    Column() {
      Text(value)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#2196F3')
      
      Text(label)
        .fontSize(13)
        .fontColor('#757575')
        .margin({ top: 4 })
    }
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  MenuSection() {
    Column() {
      this.MenuItem('⚙', '分类管理', () => {
        router.pushUrl({ url: 'pages/CategoryManager' })
      })
      
      this.MenuItem('📊', '统计分析', () => {
        router.pushUrl({ url: 'pages/StatisticsPage' })
      })
      
      this.MenuItem('🗑', '清空数据', () => {
        // 可以添加确认对话框
      }, true)
      
      this.MenuItem('ℹ', '关于', () => {
        // 显示关于信息
      })
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .padding({ left: 16, right: 16 })
  }

  @Builder
  MenuItem(icon: string, label: string, onClick: () => void, isDanger: boolean = false) {
    Row() {
      Text(icon)
        .fontSize(24)
        .margin({ right: 16 })
      
      Text(label)
        .fontSize(16)
        .fontColor(isDanger ? '#F44336' : '#1A1A1A')
        .layoutWeight(1)
      
      Text('›')
        .fontSize(24)
        .fontColor('#BDBDBD')
    }
    .width('100%')
    .height(56)
    .border({ width: { bottom: 1 }, color: '#F5F5F5' })
    .onClick(onClick)
  }
}
