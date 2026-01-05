@extends('layouts.app')

@section('content')

<!-- ================= HERO LUXE ================= -->
<section class="relative min-h-[85vh] bg-cover bg-center"
   style="background-image:url('{{ asset('images/caftan.jpg') }}'); min-height: 80vh; background-size: cover; background-position: center;">
    <!-- Overlay luxe -->
    <div class="absolute inset-0 bg-gradient-to-b from-black/80 via-black/60 to-black/90"></div>

    <div class="relative z-10 flex items-center justify-center min-h-[85vh]">
        <div class="text-center text-white px-6 max-w-4xl">
            <h1 class="text-4xl md:text-6xl font-extrabold tracking-wide mb-6">
                Caftans Marocains de Prestige
            </h1>
            <p class="text-lg md:text-xl text-gray-200 mb-10">
                Location de caftans traditionnels et modernes pour mariages,
                fiançailles et grandes occasions.
            </p>

            <a href="{{ route('caftans.index') }}"
               class="inline-block px-12 py-4 rounded-full
                      bg-emerald-600 hover:bg-emerald-700
                      text-white font-semibold tracking-wide
                      shadow-xl shadow-emerald-500/40 transition">
                Découvrir la collection
            </a>
        </div>
    </div>
</section>

<!-- ================= CATEGORIES ================= -->
<section class="bg-stone-50 py-14">
    <div class="max-w-6xl mx-auto px-4">
        <div class="text-center mb-10">
            <h2 class="text-3xl font-bold mb-2">Catégories</h2>
            <p class="text-gray-600">
                Choisissez le style qui sublime votre événement
            </p>
        </div>

        @if($categories->isNotEmpty())
            <div class="flex flex-wrap justify-center gap-4">
                @foreach($categories as $category)
                    <a href="{{ route('caftans.index', ['category' => $category->id]) }}"
                       class="px-6 py-2 rounded-full border border-emerald-400
                              text-emerald-700 font-medium
                              hover:bg-emerald-600 hover:text-white
                              transition shadow-sm">
                        {{ $category->name }}
                    </a>
                @endforeach
            </div>
        @else
            <p class="text-center text-gray-500">
                Aucune catégorie disponible.
            </p>
        @endif
    </div>
</section>

<!-- ================= FILTRE + TITRE ================= -->
<section class="max-w-6xl mx-auto px-4 py-10">
    <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
        <div>
            <h2 class="text-2xl font-bold">Nos Caftans</h2>
            <p class="text-sm text-gray-600">
                Une sélection raffinée de nos plus beaux modèles
            </p>
        </div>

        <form method="GET" action="{{ route('caftans.index') }}"
              class="flex items-center gap-2 bg-white p-3 rounded-xl shadow">
            <label class="text-sm font-medium text-gray-700">Catégorie</label>
            <select name="category"
                    class="border rounded-lg px-3 py-1 text-sm">
                <option value="">Toutes</option>
                @foreach($categories as $category)
                    <option value="{{ $category->id }}">
                        {{ $category->name }}
                    </option>
                @endforeach
            </select>
            <button class="px-4 py-1 rounded-lg bg-emerald-600 text-white text-sm hover:bg-emerald-700 transition">
                Filtrer
            </button>
        </form>
    </div>
</section>

<!-- ================= LISTE CAFTANS ================= -->
<section class="max-w-6xl mx-auto px-4 pb-20">
    <div class="grid sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-8">

        @forelse($caftans as $caftan)
            <a href="{{ route('caftans.show', $caftan->id) }}"
               class="group bg-white rounded-2xl overflow-hidden
                      shadow-md hover:shadow-2xl transition">

                <!-- Image -->
                <div class="relative aspect-[3/4] overflow-hidden">
                    @php
                        $image = $caftan->primaryImage ?: $caftan->images->first();
                    @endphp

                    @if($image)
                        <img src="{{ asset('storage/'.$image->image_path) }}"
                             alt="{{ $caftan->name }}"
                             class="w-full h-full object-cover
                                    transition-transform duration-700
                                    group-hover:scale-110">
                    @endif
                </div>

                <!-- Infos -->
                <div class="p-5">
                    <h3 class="text-lg font-semibold text-gray-800 mb-1">
                        {{ $caftan->name }}
                    </h3>

                    @if($caftan->category)
                        <p class="text-xs text-gray-500 mb-3">
                            {{ $caftan->category->name }}
                        </p>
                    @endif

                    <div class="flex items-center justify-between">
                        <span class="text-emerald-700 font-bold text-lg">
                            {{ $caftan->price_per_day }} MAD
                        </span>
                        <span class="text-sm text-gray-400">
                            / jour
                        </span>
                    </div>
                </div>
            </a>
        @empty
            <p class="col-span-full text-center text-gray-500">
                Aucun caftan disponible pour le moment.
            </p>
        @endforelse

    </div>
</section>

<!-- ================= FOOTER LUXE ================= -->
<footer class="bg-black text-gray-300 py-10">
    <div class="max-w-6xl mx-auto px-4 text-center">
        <h3 class="text-xl font-semibold text-white mb-2">
            Caftans Marocains
        </h3>
        <p class="text-sm text-gray-400">
            Élégance • Tradition • Prestige
        </p>
        <p class="text-xs text-gray-500 mt-4">
            © {{ date('Y') }} Tous droits réservés
        </p>
    </div>
</footer>

@endsection
