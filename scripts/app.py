from dash import Dash, dcc, html, Input, Output, State, ctx
import plotly.graph_objs as go
import pandas as pd

# Cargar el dataset limpio
df = pd.read_csv("mental_health_clean_viz.csv")

# Opciones de género
gender_options = [{'label': 'Todos', 'value': 'All'}] + [
    {'label': g.capitalize(), 'value': g} for g in sorted(df['gender'].dropna().unique())
]

# Inicializar app
app = Dash(__name__)

app.layout = html.Div([
    html.H2("Salud Mental y Bienestar - Comparativa entre Países (2014)"),

    dcc.Graph(id='map-plot'),

    html.Div([
        html.Button("Resetear países seleccionados", id='reset-map', n_clicks=0, style={'margin-bottom': '10px'}),
        html.Label("Filtrar por género:"),
        dcc.Dropdown(id='gender-filter', options=gender_options, value='All')
    ], style={'margin': '20px 0'}),

    dcc.Graph(id='bar-comparison'),

    # Almacenamiento interno
    dcc.Store(id='selected-countries', data=[]),
    dcc.Store(id='reset-flag', data=False)
])

# Mapa
@app.callback(
    Output('map-plot', 'figure'),
    Input('gender-filter', 'value')
)
def update_map(selected_gender):
    filtered_df = df if selected_gender == 'All' else df[df['gender'] == selected_gender]

    summary = filtered_df.groupby('country_norm').agg({
        'suicide_rate': 'mean',
        'life_ladder': 'mean',
        'log_gdp_per_capita': 'mean',
        'seek_help': lambda x: (x == "Yes").mean() * 100,
        'benefits': lambda x: (x == "Yes").mean() * 100
    }).reset_index()

    fig = go.Figure(go.Choropleth(
        locations=summary['country_norm'],
        locationmode='country names',
        z=summary['suicide_rate'],
        colorbar_title='Tasa de suicidio',
        colorscale='Reds',
        text=summary['country_norm']
    ))

    fig.update_layout(
        title="Haz clic en uno o más países para comparar",
        geo=dict(showframe=False, showcoastlines=False)
    )
    return fig

# Callback para actualizar selección de países
@app.callback(
    Output('selected-countries', 'data'),
    Output('reset-flag', 'data'),
    Input('map-plot', 'clickData'),
    Input('reset-map', 'n_clicks'),
    State('selected-countries', 'data'),
    prevent_initial_call=True
)
def update_selection(clickData, reset_clicks, selected_countries):
    trigger = ctx.triggered_id
    if trigger == 'reset-map':
        return [], True
    elif clickData and 'points' in clickData:
        country = clickData['points'][0]['location']
        if country not in selected_countries:
            selected_countries.append(country)
        return selected_countries, False
    return selected_countries, False

# Callback para actualizar gráfico de barras
@app.callback(
    Output('bar-comparison', 'figure'),
    Input('selected-countries', 'data'),
    Input('gender-filter', 'value'),
    Input('reset-flag', 'data')
)
def update_bar_chart(selected_countries, selected_gender, reset_flag):
    if reset_flag or not selected_countries:
        return go.Figure()

    filtered_df = df if selected_gender == "All" else df[df['gender'] == selected_gender]
    summary = filtered_df.groupby('country_norm').agg({
        'suicide_rate': 'mean',
        'life_ladder': 'mean',
        'log_gdp_per_capita': 'mean',
        'seek_help': lambda x: (x == "Yes").mean() * 100,
        'benefits': lambda x: (x == "Yes").mean() * 100
    }).reset_index()

    summary = summary[summary['country_norm'].isin(selected_countries)]

    fig = go.Figure()
    for _, row in summary.iterrows():
        fig.add_trace(go.Bar(
            x=["Tasa suicidio", "Felicidad", "Log PIB", "% Buscaría ayuda", "% Beneficios laborales"],
            y=[
                row['suicide_rate'],
                row['life_ladder'],
                row['log_gdp_per_capita'],
                row['seek_help'],
                row['benefits']
            ],
            name=row['country_norm']
        ))

    fig.update_layout(
        barmode='group',
        title="Comparación de indicadores por país",
        yaxis_title="Valor",
        xaxis_title="Indicador"
    )
    return fig

# Ejecutar la app
if __name__ == '__main__':
    app.run(debug=True)