import router from '@ohos.router'

interface NavItem {
  label: string
  icon: string
  page: string
}

@Component
export struct BottomNavBar {
  @Prop currentPageIndex: number = 0
  @State pressedIndex: number = -1
  
  private navItems: NavItem[] = [
    { label: '首页', icon: '🏠', page: 'pages/Index' },
    { label: '统计', icon: '📊', page: 'pages/StatisticsPage' },
    { label: '分类', icon: '📁', page: 'pages/CategoryManager' },
    { label: '我的', icon: '👤', page: 'pages/Profile' }
  ]

  onNavItemClick(index: number): void {
    if (index === this.currentPageIndex) {
      return
    }
    
    const targetPage = this.navItems[index].page
    
    try {
      router.replaceUrl({
        url: targetPage
      })
    } catch (e) {
      console.error('Navigation error:', e)
    }
  }

  build() {
    Column() {
      Row() {
        ForEach(this.navItems, (item: NavItem, index: number) => {
          Column() {
            Column() {
              Text(item.icon)
                .fontSize(index === this.currentPageIndex ? 26 : 24)
                .fontColor(index === this.currentPageIndex ? '#2196F3' : '#9E9E9E')
                .scale({ x: index === this.currentPageIndex ? 1.1 : 1, y: index === this.currentPageIndex ? 1.1 : 1 })
                .animation({
                  duration: 200,
                  curve: Curve.EaseInOut
                })
              
              Text(item.label)
                .fontSize(11)
                .fontColor(index === this.currentPageIndex ? '#2196F3' : '#757575')
                .fontWeight(index === this.currentPageIndex ? FontWeight.Medium : FontWeight.Normal)
                .margin({ top: 2 })
            }
            .width('100%')
            .height('100%')
            .justifyContent(FlexAlign.Center)
            .backgroundColor(this.pressedIndex === index ? '#F5F5F5' : '#FFFFFF')
            .scale({ x: this.pressedIndex === index ? 0.95 : 1, y: this.pressedIndex === index ? 0.95 : 1 })
            .animation({
              duration: 100,
              curve: Curve.EaseInOut
            })
          }
          .width('25%')
          .height('100%')
          .onTouch((event: TouchEvent) => {
            if (event.type === TouchType.Down) {
              this.pressedIndex = index
            } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
              this.pressedIndex = -1
              if (event.type === TouchType.Up) {
                this.onNavItemClick(index)
              }
            }
          })
        })
      }
      .width('100%')
      .height(56)
      .backgroundColor('#FFFFFF')
      .border({ width: { top: 1 }, color: '#EEEEEE' })
    }
    .width('100%')
  }
}
