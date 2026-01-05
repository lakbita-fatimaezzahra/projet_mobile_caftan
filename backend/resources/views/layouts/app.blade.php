<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{{ $settings->company_name ?? 'Riad Caftan' }}</title>
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
</head>
<body class="bg-gray-50 text-gray-900">
    @include('layouts.header')

    <main class="min-h-screen">
        @yield('content')
    </main>

    @include('layouts.footer')
</body>
</html>
