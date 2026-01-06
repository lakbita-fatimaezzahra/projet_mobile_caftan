<header class="bg-white shadow">
    <div class="max-w-6xl mx-auto px-4 py-4 flex items-center justify-between">
        <a href="{{ route('home') }}" class="flex items-center gap-2 font-semibold text-lg">
            <span>{{ $settings->company_name ?? 'Riad Caftan' }}</span>
        </a>
        <nav class="flex items-center gap-6 text-sm">
            <a href="{{ route('home') }}" class="hover:text-emerald-600">Accueil</a>
            <a href="{{ route('caftans.index') }}" class="hover:text-emerald-600">Caftans</a>
            <a href="{{ route('about') }}" class="hover:text-emerald-600">À propos</a>
            <a href="{{ route('contact') }}" class="hover:text-emerald-600">Contact</a>
        </nav>
    </div>
</header>
