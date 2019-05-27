from django.contrib import admin

from tickers.models import Ticker, Quote


class TickerAdmin(admin.ModelAdmin):

    model = Ticker

    fields = ['symbol', 'created']

    list_display = ['symbol', 'created']

    search_fields = ('symbol',)
    ordering = ('symbol',)


class QuoteAdmin(admin.ModelAdmin):

    model = Quote

    fields = [
        'ticker',
        'date',
        'high',
        'low',
        'open',
        'close',
        'volume',
        'adj_close',
        'index_adj_close',
        'scaled_adj_close',
        'sac_moving_average',
        'sac_to_sacma_ratio',
        'quotes_in_moving_average',
        'created',
    ]

    list_display = [
        'ticker',
        'date',
        'adj_close',
        'scaled_adj_close',
        'sac_moving_average',
        'sac_to_sacma_ratio',
        'quotes_in_moving_average',
    ]

    ordering = ('ticker', '-date')
    list_filter = ('ticker__symbol', 'date')


admin.site.register(Ticker, TickerAdmin)
admin.site.register(Quote, QuoteAdmin)
